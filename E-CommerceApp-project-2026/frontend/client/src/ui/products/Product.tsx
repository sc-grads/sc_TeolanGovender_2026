import { useEffect, useState } from "react";
import { config } from "../../../config";
import { type ProductProps } from "../../../type";
import ProductCard from "./ProductCard";

const Product = () => {
  const [products, setProducts] = useState<ProductProps[]>([]);

  useEffect(() => {
    fetch(`${config.baseUrl}/product`)
      .then((res) => res.json())
      .then((data) => setProducts(data));
  }, []);

  return (
    <div className="max-w-7xl mx-auto px-4 py-10">
      <h1 className="text-3xl font-semibold text-darkText mb-8">Products</h1>

      {/* Display products*/}
      {products.length === 0 ? (
        <p className="text-gray-500">No products available.</p>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
          {products.map((product) => (
            <ProductCard key={product.product_id} product={product} />
          ))}
        </div>
      )}
    </div>
  );
};

export default Product;