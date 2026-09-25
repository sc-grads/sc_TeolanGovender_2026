import { useEffect, useState } from "react";
import { config } from "../../../config";
//import AddressManagement from "./AddressManagement";

interface Address {
  address_id: number;
  address_line_1: string;
  address_line_2: string;
  city: string;
  province: string;
  postal_code: string;
}

interface AddressSelectorProps {
  selectedAddressId?: number;
  onSelect?: (address: Address) => void;
}

const AddressSelector = ({selectedAddressId, onSelect}: AddressSelectorProps) => {

  const [addresses, setAddresses] = useState<Address[]>([]);
  const [expandedAddressId, setExpandedAddressId] = useState<number | null>(null);
  //const [showManagement, setShowManagement] = useState(false);

  const fetchAddresses = async () => {
    const token = localStorage.getItem("access_token");

    const response = await fetch(`${config.baseUrl}/address`, {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    });

    if (response.ok) {
      const data = await response.json();
      setAddresses(data);
    }
  };

  useEffect(() => {
    fetchAddresses();
  }, []);

  const toggleAddress = (addressId: number) => {
    setExpandedAddressId((currentId) =>
      currentId === addressId ? null : addressId
    );
  };

  return (
    <div className="space-y-4">
      {addresses.length === 0 ? (
        <p className="text-gray-600">No saved addresses.</p>
      ) : (
        addresses.map((address) => (
          <div
            key={address.address_id}
            className="border rounded-lg p-4"
          >
            <div className="flex items-start gap-3">
              {onSelect && (
                <input
                  type="radio"
                  name="selectedAddress"
                  checked={selectedAddressId === address.address_id}
                  onChange={() => onSelect(address)}
                  className="mt-1"
                />
              )}

              <div className="flex-1">
                <div className="flex items-center justify-between gap-3">
                  <p className="font-medium">
                    {address.address_line_1}
                  </p>

                  <button
                    type="button"
                    onClick={() => toggleAddress(address.address_id)}
                    className="text-sky-600 hover:underline whitespace-nowrap"
                  >
                    {expandedAddressId === address.address_id
                      ? "Hide"
                      : "See full"}
                  </button>
                </div>

                {expandedAddressId === address.address_id && (
                  <div className="mt-3 text-gray-600 text-sm space-y-1">
                    <p>{address.address_line_1}</p>
                    <p>{address.address_line_2}</p>
                    <p>{address.city}</p>
                    <p>{address.province}</p>
                    <p>{address.postal_code}</p>
                  </div>
                )}
              </div>
            </div>
          </div>
        ))
      )}

      {/* 
      {showManagement && (
  <div className="border rounded-lg p-5 mt-6">
      <AddressManagement />
      
      <button
        type="button"
        onClick={() => setShowManagement(false)}
        className="mt-5 text-gray-600 hover:underline"
      >
        Back
      </button>
    </div>
  )}
    */}
    </div>
  );
};

export default AddressSelector;