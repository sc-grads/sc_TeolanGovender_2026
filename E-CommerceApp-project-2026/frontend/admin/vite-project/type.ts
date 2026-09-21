export interface CategoryProps {
  category_id: number;
  name: string;
}

export interface ProductProps {
  product_id: number;
  name: string;
  description: string;
  price: number;
  image_url: string;
  category_id: number;
  category?: CategoryProps;
}

export interface UserTypes {
  currentUser: {
    user_id: number;
    first_name: string;
    last_name: string;
    email: string;
    role: string;
  };
}

export interface CartItemProps {
  product_id: number;
  quantity: number;
  product: {
    product_id: number;
    name: string;
    description: string;
    price: number;
    image_url: string;
  };
}

export interface CartProps {
  cart_id: number;
  user_id: number;
  name: string;
  items: CartItemProps[];
}

export interface OrderItemProps {
  product_id: number;
  order_price: number;
  quantity: number;
  product: {
    product_id: number;
    name: string;
    description: string;
    price: number;
    image_url: string;
  };
}

export interface OrderTypes {
  order_id: number;
  user_id: number;
  order_date: string;
  order_amount: number;
  status: string;
  items: OrderItemProps[];
}