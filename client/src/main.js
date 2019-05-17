import { Socket } from "phoenix";
import Vue from "vue";
import App from "./App.vue";
import router from "./router";
import store from "./store";

Vue.config.productionTip = false;

const socket = new Socket("ws://localhost:4000/socket", { timeout: 3000 });

socket.connect();

const channel = socket.channel("game", { name: "test" });

channel
  .join()
  .receive("ok", test => console.log("catching up", test))
  .receive("error", ({ reason }) => console.log("failed join", reason))
  .receive("timeout", () => console.log("Networking issue. Still waiting..."));
console.log(socket);

new Vue({
  router,
  store,
  render: h => h(App)
}).$mount("#app");
