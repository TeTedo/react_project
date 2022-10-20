import React, { createContext, useEffect, useState } from "react";
import { Route, Routes } from "react-router-dom";
import { Shoppage } from "../components";
import { ShopMain, ShopTop, ShopBottom, ShopShoes } from "../components/Shop/";
import Slide from "../components/Slide";
import ShopSlideCom from "../components/Slide/ShopSlideCom";
import Modal_btn from "../components/Modal/Modal_btn";
import { useDispatch, useSelector } from "react-redux";
import { shopAction } from "redux/middleware/shopAction";
import Modal from "components/Modal/Modal";
export const ProductModal = createContext();
const Shop = () => {
  const slideData = useSelector((state) => state.shopSlide);
  const dispatch = useDispatch();
  const [productModal, setProductModal] = useState(false);
  const [productData, setProductData] = useState({});
  const userData = useSelector((state) => state.login);
  useEffect(() => {
    dispatch(shopAction.getSlideData());
  }, []);
  return (
    <div className="shop">
      {productModal ? (
        <Modal
          setModal={setProductModal}
          data={productData}
          type="상세 페이지 보기"
        />
      ) : (
        ""
      )}
      <ProductModal.Provider value={{ setProductModal, setProductData }}>
        <Slide
          component={ShopSlideCom}
          length={Object.keys(slideData).length || 1}
          data={slideData}
        />
      </ProductModal.Provider>

      <Routes>
        <Route exact path="/" element={<Shoppage component={ShopMain} />} />;
        <Route exact path="/top" element={<Shoppage component={ShopTop} />} />
        ;
        <Route
          exact
          path="/bottom"
          element={<Shoppage component={ShopBottom} />}
        />
        ;
        <Route
          exact
          path="/shoes"
          element={<Shoppage component={ShopShoes} />}
        />
        ;
      </Routes>

      {userData.type === "A" ? (
        <>
          <Modal_btn text={"슬라이드 관리"} />
          <Modal_btn text={"판매자신청 현황"} />
          <Modal_btn text={"판매승인"} />
        </>
      ) : (
        ""
      )}
      {userData.type === "S" ? (
        <>
          <Modal_btn text={"물건올리기"} />
          <Modal_btn text={"판매승인 확인"} />
        </>
      ) : (
        ""
      )}
    </div>
  );
};

export default Shop;
