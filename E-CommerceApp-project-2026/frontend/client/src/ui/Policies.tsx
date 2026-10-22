import Container from './Container';

const Policies = () => {
  return (
    <Container className='py-10'>
      <div className='max-w-4xl mx-auto'>
        <h1 className='text-3xl font-bold mb-8'>
          Tech Traders - Policies
        </h1>

        <div className='space-y-8 text-gray-700'>
          <section>
            <h2 className='text-xl font-semibold mb-3'>
              1. Privacy Policy
            </h2>
            <p>
              Tech Traders respects your privacy and is committed
              to protecting your personal information.
            </p>
          </section>

          <section>
            <h2 className='text-xl font-semibold mb-3'>
              2. Returns & Refunds Policy
            </h2>
            <p>
              Customers may email us to request a return when a product is defective,
              damaged or incorrect. please provide an image of 
              the defective product as well as a description in the Email. Contact details can be found at the bottom of the page.
            </p>
          </section>

          <section>
            <h2 className='text-xl font-semibold mb-3'>
              3. Shipping & Delivery Policy
            </h2>
            <p>
              Orders are processed after payment has been successfully
              received. Delivery times may vary depending on the delivery
              address, product availability, courier availability, and other
              circumstances.
            </p>
          </section>

          <section>
            <h2 className='text-xl font-semibold mb-3'>
              4. Order Cancellation Policy
            </h2>
            <p>
              Customers may contact Tech Traders to request
              cancellation of an order before the order has been dispatched.
            </p>
          </section>

          <section>
            <h2 className='text-xl font-semibold mb-3'>
              5. Product Warranty Policy
            </h2>
            <p>
              Where a product is supplied with a manufacturer's warranty,
              the warranty will be subject to the manufacturer's terms and
              conditions.
            </p>
          </section>

          <section>
            <h2 className='text-xl font-semibold mb-3'>
              6. Payment Policy
            </h2>
            <p>
              Payment must be successfully completed before an order is
              processed.
            </p>
          </section>

          <section>
            <h2 className='text-xl font-semibold mb-3'>
              7. Product Information & Pricing
            </h2>
            <p>
              We try to ensure that product descriptions,
              images, specifications, and prices displayed on the website are
              accurate.
            </p>
          </section>

          <section>
            <h2 className='text-xl font-semibold mb-3'>
              8. Website Terms & Conditions
            </h2>
            <p>
              Customers agree to use the Tech Traders website
              lawfully and not to interfere with its operation or use it for
              fraudulent purposes.
            </p>
          </section>

          <section>
            <h2 className='text-xl font-semibold mb-3'>
              9. Changes to These Policies
            </h2>
            <p>
              Tech Traders may update these policies from time to
              time. Changes will be published on this page.
            </p>
          </section>

          <section>
            <h2 className='text-xl font-semibold mb-3'>
              10. Contact Us
            </h2>
            <p>
              If you have questions regarding these policies, please contact
              Tech Traders through the contact details provided:
              
            </p>
            <p>
              <b>Contact Number:</b> 098 098 0987 
            </p>
            <p>
              <b>Email Address:</b> himi.gov@admin.com
            </p>
          </section>
        </div>
      </div>
    </Container>
  );
};

export default Policies;