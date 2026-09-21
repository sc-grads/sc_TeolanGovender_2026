import React, { useEffect, useState } from "react";
import Container from "../Container";
import { config } from "../../../config";
import { getData } from "../../lib";
import Title from "../Title";
import { Link } from "react-router-dom";
import { type CategoryProps } from "../../../type";

const Categories = () => {
  const [categories, setCategories] = useState<CategoryProps[]>([]);

  useEffect(() => {
    const fetchData = async () => {
      const endpoint = `${config?.baseUrl}/category`;

      try {
        const data = await getData(endpoint);
        setCategories(data);
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
          <Title text="Popular categories" />

          <Link
            to="/category"
            className="font-medium relative group overflow-hidden"
          >
            View All Categories
            <span className="absolute bottom-0 left-0 w-full block h-[1px] bg-gray-600 -translate-x-[100%] group-hover:translate-x-0 duration-300" />
          </Link>
        </div>

        <div className="w-full h-[1px] bg-gray-200 mt-3" />
      </div>

      <div className="grid grid-cols-3 md:grid-cols-4 lg:grid-cols-6 gap-7">
        {categories.map((item) => (
          <Link
            to={`/category/${item.category_id}`}
            key={item.category_id}
            className="w-full h-auto relative group overflow-hidden"
          >
            <div className="w-full h-32 rounded-md bg-gray-100 flex items-center justify-center group-hover:scale-110 duration-300">
              <p className="text-sm md:text-base font-bold">
                {item.name}
              </p>
            </div>
          </Link>
        ))}
      </div>
    </Container>
  );
};

export default Categories;