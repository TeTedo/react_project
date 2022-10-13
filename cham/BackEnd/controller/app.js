const express = require("express");
const app = express();
const session = require("express-session");
const { sequelize } = require("../models");
const cors = require("cors");
// DB연동
sequelize
  .sync({ force: false })
  .then(() => {
    console.log("DB연결 완료");
  })
  .catch(() => {
    console.log("DB연결 에러");
  });

//리액트랑 백엔드 연동하기 위해cors 설정
const options = {
  origin: "http://localhost:3000",
};
app.use(cors(options));

// express-session연결
app.use(
  session({
    secret: process.env.SESSION_KEY,
    resave: false,
    saveUninitialized: true,
    cookie: {
      httpOnly: true,
      sameSite: "none",
      maxAge: 5300000,
      secure: true,
    },
  })
);

//json형태의 파일을 읽을수 있게
app.use(express.json());

//라우터 불러오기, 사용
const singUp = require("../routers/signUp");
const login = require("../routers//login");
app.use(singUp, login);

app.listen(8000, () => {
  console.log("server start");
});
