const init = {
  login: false,
};
const login = (state = init, action) => {
  switch (action.type) {
    case 'LOGIN':
      return { login: true };
    case 'LOGOUT':
      return { login: false };
    default:
      return state;
  }
};

export default login;
