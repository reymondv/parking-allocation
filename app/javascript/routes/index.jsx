import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Home from '../components/Home';

const AppRoutes = (props) => (
  <Router>
    <Routes>
      <Route path='/' element={<Home />} />
    </Routes>
  </Router>
);

export default AppRoutes;
