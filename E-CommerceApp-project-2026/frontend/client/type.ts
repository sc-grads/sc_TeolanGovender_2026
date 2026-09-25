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
  quantity: number;
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
    quantity: number;
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

export interface AddressProps {
  address_id: number;
  address_line_1: string;
  address_line_2: string;
  city: string;
  province: string;
  postal_code: string;
}

export interface ProductResponse {
  products: ProductProps[];
  page: number;
  pages: number;
  total: number;
  per_page: number;
  has_next: boolean;
  has_prev: boolean;
}