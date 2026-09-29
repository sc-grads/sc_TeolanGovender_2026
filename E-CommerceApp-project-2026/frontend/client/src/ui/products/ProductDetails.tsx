import { useEffect, useRef, useState } from "react";
import { useParams } from "react-router-dom";
import { config } from "../../../config";
import { type ProductProps } from "../../../type";
import AddToCartBtn from "../cart/AddToCartBtn";
import ProductCard from "./ProductCard";
import ScrollButtons from "../ScrollButtons";

type Competitor = {
  name: string;
  retailer: string;
  price: string;
  url: string;
  image_url?: string;
};

type Review = {
  title: string;
  url: string;
  thumbnail: string;
  video_id: string;
};

const ProductDetails = () => {
  const { product_id } = useParams();

  const [product, setProduct] = useState<ProductProps | null>(null);
  const [similarProducts, setSimilarProducts] = useState<ProductProps[]>([]);

  const [competitors, setCompetitors] = useState<Competitor[]>([]);
  const [loadingCompetitors, setLoadingCompetitors] = useState(false);

  const [reviews, setReviews] = useState<Review[]>([]);
  const [loadingReviews, setLoadingReviews] = useState(false);

  const competitorScrollRef = useRef<HTMLDivElement>(null);
  const reviewScrollRef = useRef<HTMLDivElement>(null);
  const similarScrollRef = useRef<HTMLDivElement>(null);

  // Load current product
  useEffect(() => {
    const fetchProduct = async () => {
      try {
        const res = await fetch(
          `${config.baseUrl}/product/${product_id}`
        );

        const data = await res.json();
        setProduct(data);
      } catch (error) {
        console.error("Error fetching product:", error);
      }
    };

    if (product_id) {
      fetchProduct();
    }
  }, [product_id]);

  // Load similar products
  useEffect(() => {
    if (!product) return;

    const fetchSimilarProducts = async () => {
      try {
        const res = await fetch(`${config.baseUrl}/product`);
        const data: ProductProps[] = await res.json();

        const filteredProducts = data
          .filter(
            (item) =>
              item.category_id === product.category_id &&
              item.product_id !== product.product_id
          )
          .slice(0, 5);

        setSimilarProducts(filteredProducts);
      } catch (error) {
        console.error("Error fetching similar products:", error);
      }
    };

    fetchSimilarProducts();
  }, [product]);

  // Automatically load competitor prices and YouTube reviews
  useEffect(() => {
    if (!product_id) return;

    const loadAIContent = async () => {
      setLoadingCompetitors(true);
      setLoadingReviews(true);

      try {
        const [priceRes, reviewRes] = await Promise.all([
          fetch(`${config.baseUrl}/product/${product_id}/compare`),
          fetch(`${config.baseUrl}/product/${product_id}/reviews`),
        ]);

        const competitorData = await priceRes.json();
        const reviewData = await reviewRes.json();

        setCompetitors(competitorData);
        setReviews(reviewData);
      } catch (error) {
        console.error("Error loading AI content:", error);
      } finally {
        setLoadingCompetitors(false);
        setLoadingReviews(false);
      }
    };

    loadAIContent();
  }, [product_id]);

  // Scroll carousel
  const scrollCarousel = (
    ref: React.RefObject<HTMLDivElement | null>,
    direction: "left" | "right"
  ) => {
    if (!ref.current) return;

    ref.current.scrollBy({
      left: direction === "left" ? -340 : 340,
      behavior: "smooth",
    });
  };

  if (!product) {
    return (
      <div className="mx-auto max-w-7xl px-4 py-10">
        <p className="text-gray-500">
          Loading product...
        </p>
      </div>
    );
  }

  return (
    <div className="mx-auto max-w-7xl px-4 py-10">

      {/* Main Product */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-10">

        {/* Product Image */}
        <div className="flex items-center justify-center bg-white rounded-xl border border-gray-200 p-8">
          <img
            src={product.image_url}
            alt={product.name}
            className="w-full max-h-[500px] object-contain"
          />
        </div>

        {/* Product Information */}
        <div>
          <h1 className="text-3xl font-bold text-darkText">{product.name}</h1>
          <p className="mt-4 text-gray-600">{product.description}</p>
          <p className="mt-6 text-3xl font-bold text-darkText">R {Number(product.price).toFixed(2)}</p>

          <div className="mt-8 max-w-xs">
            <AddToCartBtn product={product} />
          </div>
        </div>
      </div>

      {/* Similar Products */}
      <div className="mt-14">

        <div className="flex items-center justify-between">
          <div>
            <h2 className="text-2xl font-bold text-darkText">Similar Products</h2>
          </div>

          <ScrollButtons
            onLeft={() => scrollCarousel(similarScrollRef, "left")}
            onRight={() => scrollCarousel(similarScrollRef, "right")}
          />
        </div>

        {similarProducts.length > 0 ? (
          <div
            ref={similarScrollRef}
            className="mt-6 flex gap-4 overflow-x-auto pb-4 scroll-smooth scrollbar-hide"
          >
            {similarProducts.map((similarProduct) => (
              <div
                key={similarProduct.product_id}
                className="min-w-[260px] max-w-[260px] flex-shrink-0"
              >
                <ProductCard product={similarProduct} />
              </div>
            ))}
          </div>
        ) : (
          <p className="mt-6 text-gray-500">
            No similar products found.
          </p>
        )}
      </div>

      {/* AI Section */}
      <div className="mt-16 mb-12 border-t border-gray-300 pt-10">

        <div className="flex items-center gap-3">
          <div>
            <h2 className="text-2xl font-bold text-darkText">
              AI Shopping Assistant
            </h2>

            <p className="text-sm text-gray-500">
              Powered by Tavily AI Agent.
            </p>
          </div>

        </div>
      </div>

      {/* Competitor Prices */}
      <div>

        <div className="flex items-center justify-between">

          <div>
            <h2 className="text-2xl font-bold text-darkText">
              Competitor Prices
            </h2>

            <p className="mt-2 text-sm text-gray-500">
              Product matches are searched by an AI agent and may not
              always be exact. Ensure you visit the retailer by clicking the product for exact details.
            </p>
          </div>

          <ScrollButtons
            onLeft={() => scrollCarousel(competitorScrollRef, "left")}
            onRight={() => scrollCarousel(competitorScrollRef, "right")}
          />

        </div>

        {/* Competitor Loading */}
        {loadingCompetitors && (
          <div className="mt-6 flex items-center gap-3 text-gray-500">

            <div className="h-5 w-5 animate-spin rounded-full border-2 border-gray-300 border-t-gray-800"></div>

            <p>
              Searching competitor prices...
            </p>

          </div>
        )}

        {/* Competitor Results */}
        {!loadingCompetitors && (
          competitors.length === 0 ? (
            <p className="mt-6 text-gray-500">
              No competitor prices found.
            </p>
          ) : (
            <div
              ref={competitorScrollRef}
              className="mt-6 flex gap-4 overflow-x-auto pb-4 scroll-smooth scrollbar-hide"
            >

              {competitors.map((competitor, index) => (
                <a
                  key={index}
                  href={competitor.url}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="min-w-[320px] max-w-[320px] flex-shrink-0 rounded-xl border border-gray-200 bg-white p-4 hover:shadow-md transition"
                >

                  {/* Competitor Image */}
                  <div className="h-40 flex items-center justify-center">

                    {competitor.image_url ? (
                      <img
                        src={competitor.image_url}
                        alt={competitor.name}
                        className="h-full w-full object-contain"
                      />
                    ) : (
                      <div className="text-sm text-gray-400">
                        No image available
                      </div>
                    )}

                  </div>

                  {/* Competitor Information */}
                  <div className="mt-4">

                    <h3 className="font-semibold text-darkText line-clamp-2">{competitor.name}</h3>
                    <p className="mt-1 text-sm text-gray-500">{competitor.retailer}</p>
                    <p className="mt-3 text-xl font-bold text-darkText">{competitor.price}</p>
                    
                  </div>
                </a>
              ))}

            </div>
          )
        )}
      </div>

      {/* YouTube Reviews */}
      <div className="mt-14">

        <div className="flex items-center justify-between">

          <div>
            <h2 className="text-2xl font-bold text-darkText">
              YouTube Reviews
            </h2>

            <p className="mt-2 text-sm text-gray-500">
              Watch reviews and first impressions on the product.
            </p>
          </div>

          {!loadingReviews && reviews.length > 0 && (
            <ScrollButtons
              onLeft={() => scrollCarousel(reviewScrollRef, "left")}
              onRight={() => scrollCarousel(reviewScrollRef, "right")}
            />
          )}

        </div>

        {/* Review Loading */}
        {loadingReviews && (
          <div className="mt-6 flex items-center gap-3 text-gray-500">

            <div className="h-5 w-5 animate-spin rounded-full border-2 border-gray-300 border-t-gray-800"></div>

            <p>
              Finding reviews...
            </p>

          </div>
        )}

        {/*  YouTube element */}
        {!loadingReviews && (
          reviews.length === 0 ? (
            <p className="mt-6 text-gray-500">
              No YouTube reviews found.
            </p>
          ) : (
            <div
              ref={reviewScrollRef}
              className="mt-6 flex gap-4 overflow-x-auto pb-4 scroll-smooth scrollbar-hide"
            >

              {reviews.map((review, index) => (
                <a
                  key={index}
                  href={review.url}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="min-w-[280px] max-w-[280px] flex-shrink-0 rounded-xl border border-gray-200 bg-white overflow-hidden hover:shadow-md transition"
                >

                  <img
                    src={review.thumbnail}
                    alt={review.title}
                    className="w-full h-40 object-cover"
                  />

                  <div className="p-3">
                    <p className="font-medium text-darkText line-clamp-2">{review.title}</p>
                    <div className="mt-3 text-darkText-600 text-sm font-medium"> Watch on YouTube </div>
                  </div>

                </a>
              ))}

            </div>
          )
        )}

      </div>

    </div>
  );
};

export default ProductDetails;