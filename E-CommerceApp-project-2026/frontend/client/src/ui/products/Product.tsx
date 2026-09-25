import { useEffect, useState } from "react";
import { config } from "../../../config";
import { type ProductProps } from "../../../type";
import ProductCard from "./ProductCard";

const Product = () => {
  const [products, setProducts] = useState<ProductProps[]>([]);
  const [page, setPage] = useState(1);

  const productsPerPage = 8;

  useEffect(() => {
    fetch(`${config.baseUrl}/product`)
      .then((res) => res.json())
      .then((data) => setProducts(data));
  }, []);

  // Scroll to the top when the page changes
  useEffect(() => {
    window.scrollTo({
      top: 0,
      behavior: "smooth",
    });
  }, [page]);

  // Work out which products should be displayed on the current page
  const startIndex = (page - 1) * productsPerPage;
  const endIndex = startIndex + productsPerPage;
  const displayedProducts = products.slice(startIndex, endIndex);

  // Work out how many pages are needed
  const totalPages = Math.ceil(products.length / productsPerPage);

  return (
    <div className="mx-auto max-w-7xl px-4 py-10">
      <h1 className="mb-8 text-3xl font-semibold text-darkText">
        Products
      </h1>

      {products.length === 0 ? (
        <p className="text-gray-500">No products available.</p>
      ) : (
        <>
          <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
            {displayedProducts.map((product) => (
              <ProductCard
                key={product.product_id}
                product={product}
              />
            ))}
          </div>

          {totalPages > 1 && (
            <div className="mt-10 flex items-center justify-center gap-4">
              <button
                onClick={() => setPage(page - 1)}
                disabled={page === 1}
                className="rounded-md border px-4 py-2 hover:bg-gray-100 disabled:cursor-not-allowed disabled:bg-gray-100 disabled:text-gray-400"
              >
                Previous
              </button>

              <span className="font-medium text-darkText">
                Page {page} of {totalPages}
              </span>

              <button
                onClick={() => setPage(page + 1)}
                disabled={page === totalPages}
                className="rounded-md border px-4 py-2 hover:bg-gray-100 disabled:cursor-not-allowed disabled:bg-gray-100 disabled:text-gray-400"
              >
                Next
              </button>
            </div>
          )}
        </>
      )}
    </div>
  );
};

export default Product;