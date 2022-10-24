import axios from "axios";
const reportError = (data) => {
  return async (dispatch, getState) => {
    const error = await axios.post("http://localhost:8000/error", { ...data });
    if (error.data === true) {
      alert("제출 성공");
    } else {
      alert("제출 실패");
    }
  };
};

export const errAction = { reportError };
