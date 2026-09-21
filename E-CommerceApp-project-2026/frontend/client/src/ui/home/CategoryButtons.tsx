import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { config } from "../../../config";
import { type CategoryProps, type ProductProps } from "../../../type";
import { getData } from "../../lib";
import Container from "../Container";
import Title from "../Title";

const Categories = () => {
  const [categories, setCategories] = useState<CategoryProps[]>([]);
  const [products, setProducts] = useState<ProductProps[]>([]);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const categoriesData = await getData(`${config.baseUrl}/category`);
        const productsData = await getData(`${config.baseUrl}/product`);

        setCategories(categoriesData);
        setProducts(productsData);
      } catch (error) {
        console.error("Error fetching data", error);
      }
    };

    fetchData();
  }, []);

  return (
    <Container>
      <div className="mb-10">
        <div className="flex items-center justify-between">
          <h1 className="text-3xl font-semibold text-darkText mb-8"> Search by category </h1>
        </div>

        <div className="w-full h-[1px] bg-gray-200 mt-3" />
      </div>

      <div className="grid grid-cols-3 md:grid-cols-4 lg:grid-cols-6 gap-7">
        {categories.map((item) => {
          const product = products.find((product) => product.category_id === item.category_id);

          return (
            <Link to={`/category/${item.category_id}`} key={item.category_id} className="w-full h-32 relative group overflow-hidden rounded-md">

              {product ? (
                <img src={product.image_url} alt={item.name} className="w-full h-full object-cover group-hover:scale-110 duration-300"/>
              ) : (
                <div className="w-full h-full bg-gray-100" />
              )}
            
              <div className="absolute inset-0 flex items-center justify-center bg-black/20">
                <p className="text-sm md:text-base font-bold text-white"> {item.name} </p>
              </div>
            </Link>
          );
        })}
      </div>
    </Container>
  );
};

export default Categories;