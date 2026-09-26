(function () {
    "use strict";

    document.addEventListener("DOMContentLoaded", function () {
        var email = document.getElementById("txtEmail");
        var password = document.getElementById("txtPassword");
        var buttons = document.querySelectorAll(".demo-role-button");
        if (!email || !password) return;

        Array.prototype.forEach.call(buttons, function (button) {
            button.addEventListener("click", function () {
                email.value = button.getAttribute("data-demo-email");
                password.value = "Password123";
                Array.prototype.forEach.call(buttons, function (item) {
                    item.classList.toggle("is-selected", item === button);
                    item.setAttribute("aria-pressed", item === button ? "true" : "false");
                });
                document.getElementById("btnLogin").focus();
            });
        });
    });
}());
