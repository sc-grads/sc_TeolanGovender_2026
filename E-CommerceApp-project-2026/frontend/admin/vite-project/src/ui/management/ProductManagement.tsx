import { useEffect, useState } from "react";
import { config } from "../../../config";
import { type ProductProps, type CategoryProps } from "../../../type";
import ProductCard from "../products/ProductCard";

// ---------------------ui components----------------------------
//products
const ProductManagement = () => {
  const [products, setProducts] = useState<ProductProps[]>([]);
  const [categories, setCategories] = useState<CategoryProps[]>([]);
  const [selectedProduct, setSelectedProduct] =useState<ProductProps>();
  const [showCard, setShowCard] = useState(false);

  //retieve data 
  const fetchProducts = async () => {const response = await fetch(`${config.baseUrl}/product`); const data = await response.json(); setProducts(data);};
  const fetchCategories = async () => {const response = await fetch(`${config.baseUrl}/category`); const data = await response.json(); setCategories(data);};

  //delete data
  const handleDelete = async (id: number) => {const token = localStorage.getItem("access_token");
    if (!window.confirm("Delete this product?")) return;
    await fetch(`${config.baseUrl}/product/${id}`, {
      method: "DELETE",
      headers: {
        Authorization: `Bearer ${token}`,
      },
    });

    fetchProducts();
  };

  //search
  const [search, setSearch] = useState("");
  const [category, setCategory] = useState("");

  //filter products
  const filteredProducts = products.filter((product) => {
    const matchesSearch =
      product.name.toLowerCase().includes(search.toLowerCase()) ||
      product.description.toLowerCase().includes(search.toLowerCase()) ||
      product.product_id.toString().includes(search);

    const matchesCategory =
      category === "" ||
      product.category_id?.toString() === category;

    return matchesSearch && matchesCategory;
  });

  useEffect(() => {
    fetchProducts();
    fetchCategories();
  }, []);

// ---------------------ui elements----------------------------

  return (
    <div className="p-5">
      <h1 className="text-2xl font-bold mb-4"> Product Management </h1>

      <button onClick={() => { setSelectedProduct(undefined); setShowCard(true);}} className="bg-blue-500 text-white px-4 py-2 mb-4">Add Product</button>

      {showCard && (
        <ProductCard
          product={selectedProduct}
          categories={categories}
          onClose={() => setShowCard(false)}
          onSaved={fetchProducts}
        />
      )}

      <div className="flex gap-3 mb-4">

        <input
          type="text"
          placeholder="Search products..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="border p-2 w-64"
        />

        <select
          value={category}
          onChange={(e) => setCategory(e.target.value)}
          className="border p-2"
        >
          <option value="">All Categories</option>

          {categories.map((category) => (
            <option
              key={category.category_id}
              value={category.category_id}
            >
              {category.name}
            </option>
          ))}
        </select>

      </div>

      <table className="w-full border border-gray-300">
        <thead>
          <tr className="bg-gray-200">
            <th className="border p-2">ID</th>
            <th className="border p-2">Image</th>
            <th className="border p-2">Name</th>
            <th className="border p-2">Description</th>
            <th className="border p-2">Price</th>
            <th className="border p-2">Category</th>
            <th className="border p-2">Stock</th>
            <th className="border p-2">Actions</th>
          </tr>
        </thead>

        <tbody>
          {filteredProducts.map((product) => (
            <tr key={product.product_id}>

              <td className="border p-2">{product.product_id}</td>
              <td className="border p-2"> <img src={product.image_url}className="w-16 h-16 object-contain"/></td>
              <td className="border p-2"> {product.name}</td>
              <td className="border p-2">{product.description}</td>
              <td className="border p-2"> R {Number(product.price).toFixed(2)}</td>
              <td className="border p-2">{product.category?.name} </td>
              <td className="border p-2">{product.quantity} </td>
              <td className="border p-2">
                <button onClick={() => {setSelectedProduct(product); setShowCard(true);}} className="text-blue-500 mr-3"> Edit </button>
                <button onClick={() => handleDelete(product.product_id)} className="text-red-500"> Delete </button>
              </td>

            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

export default ProductManagement;