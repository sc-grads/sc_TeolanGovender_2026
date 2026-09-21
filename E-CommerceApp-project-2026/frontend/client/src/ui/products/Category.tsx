import { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import { config } from "../../../config";
import { type ProductProps } from "../../../type";
import { getData } from "../../lib";
import ProductCard from "./ProductCard";

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
      <h1 className="text-2xl font-bold mb-5"> Category Products </h1>

      <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
        {products.map((product) => (<ProductCard key={product.product_id} product={product}/>))}
      </div>

      {products.length === 0 && (<p>No products found in this category.</p>)}
    </div>
  );
};

export default Category;