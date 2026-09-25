import { deliveryimage } from "../../assets/images";

interface OrderSuccessProps {
  onClose: () => void;
}

const OrderSuccess = ({ onClose }: OrderSuccessProps) => {
  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
      <div className="w-full max-w-md rounded-xl bg-white p-8 shadow-xl text-left">

        <h2 className="text-2xl font-semibold mb-3">
          Order Successful
        </h2>


        <div className="mb-5 flex items-center justify-center">
          <img
            src= {deliveryimage} 
            alt="Delivery animation"
            className="h-15 w-15 object-cover"
          />
        </div>

        

        <p className="text-gray-600 mb-6"> Your order is on its way. A confirmation email will be sent to you.</p>

        <button
          onClick={onClose}
          className="w-full bg-greenText text-white py-3 rounded-lg hover:bg-skyText transition"
        >
          Continue Shopping
        </button>
      </div>
    </div>
  );
};

export default OrderSuccess;