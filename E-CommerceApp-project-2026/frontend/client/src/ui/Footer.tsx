import React from 'react';
import { Link } from 'react-router-dom';
import Container from './Container';
import { payment } from '../assets';
import FooterTop from './FooterTop';

const Footer = () => {
  return (
    <div className='mt-10'>
      <FooterTop />

      <Container className='flex flex-col md:flex-row items-center gap-4 justify-between'>
        <p>@2026 Tech Traders solutions. All rights reserved</p>

        <Link
          to='/policies'
          className='text-sm hover:underline'
        >
          <h2 className="text-xl sm:text-1xl font-bold tracking-tight text-gray-900">Policies and Concerns</h2>
        </Link>

        <img src={payment} alt='payment-img' />
      </Container>
    </div>
  );
};

export default Footer;