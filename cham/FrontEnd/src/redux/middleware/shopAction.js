import axios from "axios";

const uploadGoodsToServer = (props) => {
  return async (dispatch, getState) => {
    const { formData, config } = props;
    await axios.post("http://localhost:8000/shop/uploads", formData, config);
  };
};
const uploadSlideToServer = (props) => {
  return async (dispatch, getState) => {
    const { formData, config } = props;
    const slideData = await axios.post(
      "http://localhost:8000/shop/uploadsSlide",
      formData,
      config
    );
    dispatch({ type: "ADDSLIDE", payload: slideData.data });
  };
};
const getShopData = () => {
  return async (dispatch, getState) => {
    const goodsData = await axios.get("http://localhost:8000/shop/data");
    dispatch({ type: "SHOPDATA", payload: goodsData.data });
  };
};
const getPermissionData = () => {
  return async (dispatch, getState) => {
    const goodsData = await axios.get("http://localhost:8000/shop/permission");
    dispatch({ type: "PERMISSION", payload: goodsData.data });
  };
};
const getSlideData = () => {
  return async (dispatch, getState) => {
    const slideData = await axios.get("http://localhost:8000/shop/slide");
    dispatch({ type: "GETSLIDE", payload: slideData.data });
  };
};
const deleteSlideData = (props) => {
  return async (dispatch, getState) => {
    const slideData = await axios.post(
      "http://localhost:8000/shop/deleteSlide",
      { id: props }
    );
    dispatch({ type: "GETSLIDE", payload: slideData.data });
  };
};
const getPermissionCheck = (user_id) => {
  return async (dispatch, getState) => {
    const goodsData = await axios.post(
      "http://localhost:8000/shop/permissionCheck",
      { user_id }
    );
    dispatch({ type: "PERMISSION", payload: goodsData.data });
  };
};

const permissionAction = (action, id) => {
  return async (dispatch, getState) => {
    const goodsData = await axios.post(
      "http://localhost:8000/shop/permission",
      { type: action, id }
    );
    dispatch({ type: "PERMISSION", payload: goodsData.data });
  };
};

const addToCart = (data) => {
  return async (dispatch, getState) => {
    await axios.post("http://localhost:8000/shop/cart", { ...data });
    alert("장바구니에 추가되었습니다.");
  };
};
const getCartData = (user_id) => {
  return async (dispatch, getState) => {
    const cartData = await axios.post("http://localhost:8000/shop/cartData", {
      user_id,
    });
    dispatch({ type: "CART", payload: { ...cartData.data } });
  };
};
export const shopAction = {
  uploadGoodsToServer,
  getPermissionData,
  permissionAction,
  getPermissionCheck,
  getShopData,
  uploadSlideToServer,
  getSlideData,
  deleteSlideData,
  addToCart,
  getCartData,
};
