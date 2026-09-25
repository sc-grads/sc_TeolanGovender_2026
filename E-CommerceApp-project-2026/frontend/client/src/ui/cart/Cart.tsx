import { useCallback, useEffect, useState } from "react";
import { config } from "../../../config";
import { type CartProps } from "../../../type";

import CartProduct from "./CartProduct";
import OrderSummary from "./OrderSummary";
import OrderConfirmation from "../order/OrderConfirmation";
import StripeCheckout from "../checkout/StripeCheckout";
import Awesome from "../order/Awesome";

interface Address {
  address_id: number;
  address_line_1: string;
  address_line_2: string;
  city: string;
  province: string;
  postal_code: string;
}

const Cart = () => {
  const [cart, setCart] = useState<CartProps | null>(null);
  const [loading, setLoading] = useState(true);

  const [showConfirmation, setShowConfirmation] = useState(false);
  const [showCheckout, setShowCheckout] = useState(false);
  const [showSuccess, setShowSuccess] = useState(false);

  const [selectedAddress, setSelectedAddress] = useState<Address | null>(
    null
  );

  const [user, setUser] = useState<{
    first_name: string;
    last_name: string;
    email: string;
  } | null>(null);

  const fetchCart = useCallback(async () => {
    const token = localStorage.getItem("access_token");

    if (!token) {
      return setLoading(false);
    }

    const response = await fetch(`${config.baseUrl}/cart`, {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    });

    if (response.ok) {
      setCart(await response.json());
    }

    setLoading(false);
  }, []);

  const fetchUser = useCallback(async () => {
    const token = localStorage.getItem("access_token");

    if (!token) return;

    const response = await fetch(`${config.baseUrl}/profile`, {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    });

    if (response.ok) {
      setUser(await response.json());
    }
  }, []);

  useEffect(() => {
    fetchCart();
    fetchUser();
  }, [fetchCart, fetchUser]);

  const handleCheckout = async (paymentIntentId: string) => {
    const token = localStorage.getItem("access_token");
    
    if (!token) return;
    
    if (!selectedAddress) {
      alert("Please select a delivery address.");
      return;
    }
  
    const response = await fetch(`${config.baseUrl}/checkout`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify({
        address_id: selectedAddress.address_id,
        payment_intent_id: paymentIntentId,
      }),
    });
  
    if (response.ok) {
      setShowCheckout(false);
      setShowSuccess(true);
      await fetchCart();
    } else {
      const error = await response.json();
    
      throw new Error(
        error.message ||
          "Something went wrong while creating your order."
      );
    }
  };

  const total =
    cart?.items.reduce(
      (sum, item) => sum + item.product.price * item.quantity,
      0
    ) ?? 0;

  const itemCount =
    cart?.items.reduce((sum, item) => sum + item.quantity, 0) ?? 0;

  if (loading) {
    return (
      <div className="max-w-6xl mx-auto px-4 py-20 text-center">
        Loading cart...
      </div>
    );
  }

  if (!cart || cart.items.length === 0) {
    if (showSuccess) {
      return (
        <>
          <div className="max-w-6xl mx-auto px-4 py-20 text-center">
            <h2 className="text-2xl font-semibold mb-3">
              Cart is empty
            </h2>
          </div>

          <Awesome onClose={() => setShowSuccess(false)} />
        </>
      );
    }

    return (
      <div className="max-w-6xl mx-auto px-4 py-20 text-center">
        <h2 className="text-2xl font-semibold mb-3">
          Cart is empty
        </h2>
      </div>
    );
  }

  return (
    <>
      <div className="max-w-6xl mx-auto px-3 sm:px-4 py-6 sm:py-10">

        <h1 className="text-2xl sm:text-3xl font-semibold mb-6 sm:mb-8">
          Cart
        </h1>

        <div className="grid grid-cols-1 lg:grid-cols-[2fr_1fr] gap-6 lg:gap-10">

          {/* Cart products */}
          <div className="border-2 border-slate-500 rounded-lg p-3 sm:p-6">
            {cart.items.map((item) => (
              <CartProduct
                key={item.product.product_id}
                item={item}
                onCartUpdated={fetchCart}
              />
            ))}
          </div>

          {/* Order summary */}
          <OrderSummary
            total={total}
            itemCount={itemCount}
            selectedAddressId={selectedAddress?.address_id}
            onAddressSelect={setSelectedAddress}
            onCheckout={() => {
              if (!selectedAddress) {
                alert("Please select a delivery address.");
                return;
              }

              setShowConfirmation(true);
            }}
          />

        </div>
      </div>

      {showConfirmation && selectedAddress && user && (
        <OrderConfirmation
          cart={cart}
          address={selectedAddress}
          firstName={user.first_name}
          lastName={user.last_name}
          email={user.email}
          total={total}
          onConfirm={() => {
            setShowConfirmation(false);
            setShowCheckout(true);
          }}
          onClose={() => setShowConfirmation(false)}
        />
      )}

      {showCheckout && (
        <StripeCheckout
          amount={total}
          onPaymentSuccess={handleCheckout}
          onClose={() => setShowCheckout(false)}
        />
      )}

      {showSuccess && (
        <Awesome onClose={() => setShowSuccess(false)} />
      )}
    </>
  );
};

export default Cart;