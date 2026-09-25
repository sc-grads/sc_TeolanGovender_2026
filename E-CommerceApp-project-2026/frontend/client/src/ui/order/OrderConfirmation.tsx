import type { CartProps } from "../../../type";

interface Address {
  address_id: number;
  address_line_1: string;
  address_line_2: string;
  city: string;
  province: string;
  postal_code: string;
}

interface OrderConfirmationProps {
  cart: CartProps;
  address: Address;
  firstName: string;
  lastName: string;
  email: string;
  total: number;
  onConfirm: () => void;
  onClose: () => void;
}

const OrderConfirmation = ({
  cart,
  address,
  firstName,
  lastName,
  email,
  total,
  onConfirm,
  onClose,
}: OrderConfirmationProps) => {
  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
      <div className="w-full max-w-2xl max-h-[90vh] overflow-y-auto rounded-xl bg-white p-6 shadow-xl">
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-2xl font-semibold">
            Confirm Your Order
          </h2>

          <button
            onClick={onClose}
            className="text-2xl text-gray-500 hover:text-gray-800"
          >
            ×
          </button>
        </div>

        {/* Customer Details */}
        <section className="mb-6">
          <h3 className="text-lg font-semibold mb-3">
            Customer Details
          </h3>

          <div className="rounded-lg border p-4">
            <p>
              <span className="font-medium">Name:</span>{" "}
              {firstName} {lastName}
            </p>

            <p>
              <span className="font-medium">Email:</span>{" "}
              {email}
            </p>
          </div>
        </section>

        {/* Delivery Address */}
        <section className="mb-6">
          <h3 className="text-lg font-semibold mb-3">
            Delivery Address
          </h3>

          <div className="rounded-lg border p-4">
            <p>{address.address_line_1}</p>
            <p>{address.address_line_2}</p>
            <p>{address.city}</p>
            <p>{address.province}</p>
            <p>{address.postal_code}</p>
          </div>
        </section>

        {/* Products */}
        <section className="mb-6">
          <h3 className="text-lg font-semibold mb-3">
            Order Items
          </h3>

          <div className="rounded-lg border divide-y">
            {cart.items.map((item) => (
              <div
                key={item.product.product_id}
                className="flex justify-between gap-4 p-4"
              >
                <div>
                  <p className="font-medium">
                    {item.product.name}
                  </p>

                  <p className="text-sm text-gray-500">
                    Quantity: {item.quantity}
                  </p>

                  <p className="text-sm text-gray-500">
                    R {item.product.price.toFixed(2)} each
                  </p>
                </div>

                <p className="font-semibold whitespace-nowrap">
                  R{" "}
                  {(item.product.price * item.quantity).toFixed(2)}
                </p>
              </div>
            ))}
          </div>
        </section>

        {/* Total */}
        <div className="flex justify-between border-t pt-5 mb-6">
          <span className="text-xl font-semibold">
            Total
          </span>

          <span className="text-xl font-bold">
            R {total.toFixed(2)}
          </span>
        </div>

        {/* Actions */}
        <div className="flex gap-3">
          <button
            onClick={onClose}
            className="flex-1 rounded-lg border py-3 font-medium hover:bg-gray-100 transition"
          >
            Back
          </button>

          <button
            onClick={onConfirm}
            className="flex-1 rounded-lg bg-greenText py-3 text-white font-medium hover:bg-skyText transition"
          >
            Pay & Confirm Order
          </button>
        </div>
      </div>
    </div>
  );
};

export default OrderConfirmation;