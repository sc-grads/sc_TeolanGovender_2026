import { type ProductProps } from "../../../type";
import AddToCartBtn from "../cart/AddToCartBtn";

interface ProductCardProps {
  product: ProductProps;
}

const ProductCard = ({ product }: ProductCardProps) => {
  return (
    <div className="bg-white rounded-xl border border-gray-200 overflow-hidden shadow-sm hover:shadow-md transition">
        <img src={product.image_url} alt={product.name} className="w-full h-56 object-contain" />

      <div className="p-4 flex flex-col gap-4">
          <div>
            <h2 className="text-lg font-semibold text-darkText">{product.name}</h2>

            <p className="text-gray-500 text-sm mt-2 line-clamp-2">{product.description}</p>

            <p className="text-xl font-bold text-darkText mt-4">R {Number(product.price).toFixed(2)}</p>
          </div>

          <AddToCartBtn product={product} />
      </div>
      
    </div>
  );
};

export default ProductCard;