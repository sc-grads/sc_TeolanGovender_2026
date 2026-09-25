import { type ProductProps } from "../../../type";
import AddToCartBtn from "../cart/AddToCartBtn";

const QuantityMessage = (quantity: number) => {
  if (quantity < 10 && quantity > 0) {
    return (
      <p className="text-red-600 text-sm">Grab one before it's gone. Only {quantity} left</p>
    );
  }
  return null;
};

const OutofStockMessage = (quantity: number) => {
  if (quantity === 0) {
    return <p className="text-red-600 text-sm"> You're out of luck </p>;
  }
  return null;
};

interface ProductCardProps {
  product: ProductProps;
  setSearchText?: any;
}

const ProductCard = ({ product }: ProductCardProps) => {
  return (
    <div className="bg-white rounded-xl border border-gray-200 overflow-hidden shadow-sm hover:shadow-md transition flex flex-col h-full">
      <img src={product.image_url} alt={product.name} className="w-full h-56 object-contain"/>

      <div className="p-4 flex flex-col justify-between flex-1">
        <div>
          {/* product details */}
          <h2 className="text-lg font-semibold text-darkText line-clamp-1 h-7">{product.name}</h2>

          <div className="relative group mt-2 min-h-[2.5rem]">
            <p className="text-gray-500 text-sm line-clamp-2 cursor-pointer">{product.description}</p>

            {product.description && product.description.length > 80 && (
              <div className="absolute top-0 left-0 w-full p-3 bg-white border border-gray-200 shadow-xl rounded-lg opacity-0 pointer-events-none group-hover:opacity-100 group-hover:pointer-events-auto transition-all duration-200 z-20 text-sm text-gray-700"> 
              {product.description}
              </div>
            )}
          </div>

          <p className="text-xl font-bold text-darkText mt-4"> R {Number(product.price).toFixed(2)}</p>

          <div className="mt-2 min-h-[1.25rem]"> {QuantityMessage(product.quantity)} {OutofStockMessage(product.quantity)}</div>
        </div>

        <div className="mt-4 pt-2"> 
          <AddToCartBtn product={product} /> 
        </div>
      </div>
    </div>
  );
};

export default ProductCard;