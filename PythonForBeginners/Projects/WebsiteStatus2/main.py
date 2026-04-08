import asyncio
from asyncio import Future
from datetime import datetime
from typing import Any
import requests
from requests import Response


# Async function to check website status
async def check_status(url: str) -> dict[str, int | str]:
    start_time: datetime = datetime.now()

    try:
        # Run blocking request in a separate thread
        response: Response = await asyncio.to_thread(requests.get, url)

        end_time: datetime = datetime.now()

        return {
            "website": url,
            "status": response.status_code,
            "start_time": f"{start_time:%H:%M:%S}",
            "end_time": f"{end_time:%H:%M:%S}",
        }

    except Exception as e:
        return {
            "website": url,
            "error": str(e),
            "start_time": f"{start_time:%H:%M:%S}",
            "end_time": f"{datetime.now():%H:%M:%S}",
        }


# Main async entry point
async def main() -> None:
    print("Fetching results...")

    tasks: Future = asyncio.gather(
        check_status("https://bing.com"),
        check_status("https://google.com"),
        check_status("https://apple.com"),
        check_status("https://bbc.com"),
        check_status("https://lol.thisdoesnotexist"),  # will fail
        return_exceptions=True
    )

    results: list[dict[str, Any]] = await tasks

    print("\nAll results:")
    print(results)

    print("\nFormatted results:")
    for result in results:
        print(result)


if __name__ == "__main__":
    asyncio.run(main())