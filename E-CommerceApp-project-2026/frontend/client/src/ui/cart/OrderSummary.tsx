import AddressSelector from "../profile/AddressSelector";
import type { AddressProps } from "../../../type";
import { useNavigate } from "react-router-dom";


type OrderSummaryProps = {
  total: number;
  itemCount: number;
  selectedAddressId?: number;
  onAddressSelect: (address: AddressProps) => void;
  onCheckout: () => void;
};

const OrderSummary = ({
  total,
  itemCount,
  selectedAddressId,
  onAddressSelect,
  onCheckout,
}: OrderSummaryProps) => {

  const hasSelectedAddress = selectedAddressId !== undefined;
  const navigate = useNavigate();

  return (
    <div className="border-2 border-slate-500 rounded-lg p-6 mb-6">
      <h2 className="text-xl font-semibold mb-6">
        Order Summary
      </h2>

      <div className="flex justify-between mb-4">
        <span>Items:</span>
        <span>{itemCount}</span>
      </div>

      <div className="flex justify-between mb-6">
        <span>Total:</span>
        <span className="font-bold text-xl">
          R {total.toFixed(2)}
        </span>
      </div>

      <div className="mb-6">
        <h3 className="font-semibold mb-3">
          Delivery Address
        </h3>

        <button
                  type="button"
                  onClick={() => navigate("/profile")}
                  className="text-sky-600 hover:underline mt-3"> Edit </button>

        <AddressSelector
          selectedAddressId={selectedAddressId}
          onSelect={onAddressSelect}
        />
      </div>

      <div
        title={
          hasSelectedAddress
            ? ""
            : "Select an address before checking out."
        }
      >
        <button
          onClick={onCheckout}
          disabled={!hasSelectedAddress}
          className={`w-full py-3 rounded-lg transition ${
            hasSelectedAddress
              ? "bg-greenText text-white hover:bg-skyText"
              : "bg-gray-300 text-gray-500 cursor-not-allowed"
          }`}
        >
          Checkout
        </button>
      </div>
    </div>
  );
};

export default OrderSummary;