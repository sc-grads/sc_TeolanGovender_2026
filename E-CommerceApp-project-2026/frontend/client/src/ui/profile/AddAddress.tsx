{/* this interface passes data out */}
export interface AddressFormData {
  address_line_1: string;
  address_line_2: string;
  city: string;
  province: string;
  postal_code: string;
}

{/* this interface accepts  data in from parent component */}
interface AddAddressProps {
  address: AddressFormData;
  onChange: (address: AddressFormData) => void;
}

const AddAddress = ({
  address,
  onChange,
}: AddAddressProps) => {
  const handleChange = (
    field: keyof AddressFormData,
    value: string
  ) => {
    onChange({
      ...address,
      [field]: value,
    });
  };

  return (
    <>
      {/* Address Line 1 */}
      <div>
        <label
          htmlFor="address_line_1"
          className="block text-sm font-medium text-gray-700 mb-2"
        >
          Address Line 1
        </label>

        <input
          id="address_line_1"
          type="text"
          value={address.address_line_1}
          onChange={(e) =>
            handleChange("address_line_1", e.target.value)
          }
          required
          placeholder="unit number, street address"
          className="w-full rounded-md border border-gray-300 px-4 py-2.5 outline-none focus:ring-2 focus:ring-sky-500"
        />
      </div>

      {/* Address Line 2 */}
      <div>
        <label
          htmlFor="address_line_2"
          className="block text-sm font-medium text-gray-700 mb-2"
        >
          Address Line 2
        </label>

        <input
          id="address_line_2"
          type="text"
          value={address.address_line_2}
          onChange={(e) =>
            handleChange("address_line_2", e.target.value)
          }
          required
          placeholder="complex, apartment, building, floor, etc."
          className="w-full rounded-md border border-gray-300 px-4 py-2.5 outline-none focus:ring-2 focus:ring-sky-500"
        />
      </div>

      {/* City */}
      <div>
        <label
          htmlFor="city"
          className="block text-sm font-medium text-gray-700 mb-2"
        >
          City
        </label>

        <input
          id="city"
          type="text"
          value={address.city}
          onChange={(e) =>
            handleChange("city", e.target.value)
          }
          required
          placeholder="Enter your city"
          className="w-full rounded-md border border-gray-300 px-4 py-2.5 outline-none focus:ring-2 focus:ring-sky-500"
        />
      </div>

      {/* Province */}
      <div>
        <label
          htmlFor="province"
          className="block text-sm font-medium text-gray-700 mb-2"
        >
          Province
        </label>

        <input
          id="province"
          type="text"
          value={address.province}
          onChange={(e) =>
            handleChange("province", e.target.value)
          }
          required
          placeholder="Enter your province"
          className="w-full rounded-md border border-gray-300 px-4 py-2.5 outline-none focus:ring-2 focus:ring-sky-500"
        />
      </div>

      {/* Postal Code */}
      <div>
        <label
          htmlFor="postal_code"
          className="block text-sm font-medium text-gray-700 mb-2"
        >
          Postal Code
        </label>

        <input
          id="postal_code"
          type="text"
          value={address.postal_code}
          onChange={(e) =>
            handleChange("postal_code", e.target.value)
          }
          required
          placeholder="Enter your postal code"
          className="w-full rounded-md border border-gray-300 px-4 py-2.5 outline-none focus:ring-2 focus:ring-sky-500"
        />
      </div>
    </>
  );
};

export default AddAddress;