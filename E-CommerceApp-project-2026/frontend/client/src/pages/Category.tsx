import { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import { config } from "../../config";
import { type ProductProps } from "../../type";
import { getData } from "../lib";

const Category = () => {
  const { categoryId } = useParams();

  const [products, setProducts] = useState<ProductProps[]>([]);

  useEffect(() => {
    const fetchProducts = async () => {
      try {
        const data = await getData(`${config.baseUrl}/product`);

        const filteredProducts = data.filter(
          (product: ProductProps) =>
            product.category_id === Number(categoryId)
        );

        setProducts(filteredProducts);
      } catch (error) {
        console.error("Error fetching products", error);
      }
    };

    fetchProducts();
  }, [categoryId]);

  return (
    <div className="p-5">
      <h1 className="text-2xl font-bold mb-5">
        Category Products
      </h1>

      <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-5">
        {products.map((product) => (
          <div key={product.product_id} className="border p-3 rounded-md">
            <img
              src={product.image_url}
              alt={product.name}
              className="w-full h-48 object-contain"
            />

            <h2 className="font-bold mt-2">
              {product.name}
            </h2>

            <p>R{product.price}</p>
          </div>
        ))}
      </div>

      {products.length === 0 && (
        <p>No products found in this category.</p>
      )}
    </div>
  );
};

export default Category;