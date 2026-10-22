import os
import re
import requests
from concurrent.futures import ThreadPoolExecutor
from tavily import TavilyClient


tavily = TavilyClient(api_key=os.getenv("TAVILY_API_KEY"))


def product_matches(product_name, result_title):

    product_words = [
        word.lower()
        for word in product_name.split()
        if len(word) > 2
    ]

    title = result_title.lower()

    matches = sum(
        word in title
        for word in product_words
    )

    return matches / len(product_words) >= 0.7


def get_page_data(url):

    try:
        response = requests.get(
            url,
            timeout=3,
            headers={"User-Agent": "Mozilla/5.0"}
        )

        html = response.text

        # Image
        image_match = re.search(
            r'<meta[^>]+property=["\']og:image["\'][^>]+content=["\']([^"\']+)',
            html,
            re.IGNORECASE
        )

        image_url = image_match.group(1) if image_match else None

        # Price patterns (most common SA ecommerce formats)
        price_patterns = [
            r'"price"\s*:\s*"?(R?\s?\d[\d\s,]*\.?\d{0,2})',
            r'content="R\s?(\d[\d\s,]*\.?\d{0,2})"\s*property="product:price:amount"',
            r'property="product:price:amount"\s*content="([\d\s,]+\.?\d{0,2})"',
            r'R\s?\d{2,3}(?:[,\s]\d{3})*(?:\.\d{2})?'
        ]

        price = None

        for pattern in price_patterns:
            match = re.search(pattern, html, re.IGNORECASE)
            if match:
                value = match.group(1) if match.lastindex else match.group(0)

                value = value.strip()

                if not value.startswith("R"):
                    value = f"R {value}"

                price = value
                break

        return image_url, price

    except Exception:
        return None, None


def get_price(content):

    patterns = [
        r'R\s?\d{1,3}(?:[,\s]\d{3})*(?:\.\d{2})?',
        r'R\d{1,3}(?:[,\s]\d{3})*(?:\.\d{2})?',
        r'\d{1,3}(?:[,\s]\d{3})*\.\d{2}\s*ZAR',
    ]

    for pattern in patterns:
        match = re.search(pattern, content, re.IGNORECASE)

        if match:
            price = match.group(0).strip()

            # Don't accept just "R"
            if re.search(r'\d', price):
                return price

    return None


def search_retailer(product_name, retailer, product_image_url):

    retailer_name, domain = retailer

    query = f'"{product_name}" site:{domain}'

    try:
        response = tavily.search(
            query=query,
            search_depth="basic",
            max_results=1
        )

        if not response["results"]:
            return None

        result = response["results"][0]

        title = result["title"]
        url = result["url"]
        content = result["content"]

        # Ignore results that don't closely match our product
        if not product_matches(product_name, title):
            return None

        # Find price
        image_url, page_price = get_page_data(url)

        if not image_url:
            image_url = product_image_url

        # Prefer the retailer page's price over Tavily's snippet
        if page_price:
            price = page_price
        else:
            price = get_price(content) or "Price unavailable"

        return {
            "name": title,
            "retailer": retailer_name,
            "price": price,
            "url": url,
            "image_url": image_url
        }

    except Exception as error:
        print(f"Error searching {retailer_name}: {error}")
        return None


def compare_product(product_name, product_image_url):

    print(f"Searching Tavily for: {product_name}")

    retailers = [
        ("Takealot", "takealot.com"),
        ("Amazon", "amazon.co.za"),
        ("Technomobi", "technomobi.co.za"),
        ("Game", "game.co.za"),
        ("Makro", "makro.co.za"),
        ("Incredible", "incredible.co.za"),
        ("Wootware", "wootware.co.za"),
        ("Evetech", "evetech.co.za"),
        ("Computer Mania", "computermania.co.za"),
        ("PriceCheck", "pricecheck.co.za")
    ]

    # Search all retailers at the same time
    with ThreadPoolExecutor(max_workers=10) as executor:

        results = executor.map(
            lambda retailer: search_retailer(
                product_name,
                retailer,
                product_image_url
            ),
            retailers
        )

    return [
        result
        for result in results
        if result is not None
    ]

def find_youtube_reviews(product_name):

    response = tavily.search(
        query=f'"{product_name}" review',
        include_domains=["youtube.com"],
        search_depth="basic",
        max_results=5
    )

    reviews = []

    for result in response["results"]:

        url = result["url"]

        # Extract YouTube video ID
        video_id = None

        match = re.search(r"v=([A-Za-z0-9_-]{11})", url)
        if match:
            video_id = match.group(1)

        shorts = re.search(r"shorts/([A-Za-z0-9_-]{11})", url)
        if shorts:
            video_id = shorts.group(1)

        if not video_id:
            continue

        reviews.append({
            "title": result["title"],
            "url": url,
            "video_id": video_id,
            "thumbnail": f"https://img.youtube.com/vi/{video_id}/hqdefault.jpg"
        })

    return reviews