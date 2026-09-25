import { useState } from "react";
import { config } from "../../../config";
import { type ProductProps, type CategoryProps } from "../../../type";

interface ProductCardProps {
  product?: ProductProps;
  categories: CategoryProps[];
  onClose: () => void;
  onSaved: () => void;
}

const ProductCard = ({
  product,
  categories,
  onClose,
  onSaved,
}: ProductCardProps) => {

  const [name, setName] = useState(product?.name || "");
  const [description, setDescription] = useState(product?.description || "");
  const [price, setPrice] = useState(product?.price.toString() || "");
  const [quantity, setQuantity] = useState(product?.quantity.toString() || "");
  const [imageUrl, setImageUrl] = useState(product?.image_url || "");
  const [categoryId, setCategoryId] = useState(
    product?.category_id.toString() || ""
  );

  const [uploading, setUploading] = useState(false);

  const uploadImage = async (file: File) => {
    const formData = new FormData();

    formData.append("file", file);
    formData.append("upload_preset", "techtraders");

    setUploading(true);

    const response = await fetch(
      "https://api.cloudinary.com/v1_1/dhwla7huw/image/upload",
      {
        method: "POST",
        body: formData,
      }
    );

    const data = await response.json();

    setImageUrl(data.secure_url);
    setUploading(false);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    const token = localStorage.getItem("access_token");

    const productData = {
      name,
      description,
      price: Number(price),
      image_url: imageUrl,
      quantity: Number(quantity),
      category_id: Number(categoryId),
    };

    const response = await fetch(
      product
        ? `${config.baseUrl}/product/${product.product_id}`
        : `${config.baseUrl}/product`,
      {
        method: product ? "PUT" : "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify(productData),
      }
    );

    if (response.ok) {
      onSaved();
      onClose();
    }
  };

  return (
    <div className="border p-5 mb-5">

      <h2 className="text-xl font-bold mb-4">
        {product ? "Edit Product" : "Add Product"}
      </h2>

      <form onSubmit={handleSubmit}>

        <input
          type="text"
          placeholder="Product name"
          value={name}
          onChange={(e) => setName(e.target.value)}
          className="border p-2 w-full mb-3"
        />

        <textarea
          placeholder="Description"
          value={description}
          onChange={(e) => setDescription(e.target.value)}
          className="border p-2 w-full mb-3"
        />

        <input
          type="number"
          placeholder="Price"
          value={price}
          onChange={(e) => setPrice(e.target.value)}
          className="border p-2 w-full mb-3"
        />

        <input
          type="number"
          placeholder="Quantity"
          value={quantity}
          onChange={(e) => setQuantity(e.target.value)}
          className="border p-2 w-full mb-3"
        />

        <select
          value={categoryId}
          onChange={(e) => setCategoryId(e.target.value)}
          className="border p-2 w-full mb-3"
        >
          <option value="">Select Category</option>

          {categories.map((category) => (
            <option
              key={category.category_id}
              value={category.category_id}
            >
              {category.name}
            </option>
          ))}
        </select>

        <input
          type="file"
          accept="image/*"
          onChange={(e) => {
            if (e.target.files) {
              uploadImage(e.target.files[0]);
            }
          }}
          className="mb-3"
        />

        {uploading && (
          <p className="mb-3">Uploading image...</p>
        )}

        {imageUrl && (
          <img
            src={imageUrl}
            className="w-32 h-32 object-contain mb-3"
          />
        )}

        <button
          type="submit"
          disabled={uploading}
          className="bg-green-500 text-white px-4 py-2 mr-2"
        >
          {product ? "Update Product" : "Add Product"}
        </button>

        <button
          type="button"
          onClick={onClose}
          className="bg-gray-500 text-white px-4 py-2"
        >
          Cancel
        </button>

      </form>
    </div>
  );
};

export default ProductCard;