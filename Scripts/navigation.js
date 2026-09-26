(function () {
    "use strict";

    function closeNavigation(button, container) {
        button.setAttribute("aria-expanded", "false");
        button.setAttribute("aria-label", button.dataset.closeLabel || "Open navigation");
        container.classList.remove("is-nav-open");
    }

    document.addEventListener("DOMContentLoaded", function () {
        var toggles = document.querySelectorAll("[data-nav-toggle]");

        toggles.forEach(function (button) {
            var nav = document.getElementById(button.getAttribute("aria-controls"));
            var container = button.closest(".public-header, .app-sidebar");
            if (!nav || !container) return;

            button.dataset.closeLabel = button.getAttribute("aria-label");
            button.addEventListener("click", function () {
                var isOpen = button.getAttribute("aria-expanded") === "true";
                button.setAttribute("aria-expanded", String(!isOpen));
                button.setAttribute("aria-label", isOpen ? button.dataset.closeLabel : "Close navigation");
                container.classList.toggle("is-nav-open", !isOpen);
            });

            nav.addEventListener("click", function (event) {
                if (event.target.closest("a")) closeNavigation(button, container);
            });

            container.addEventListener("keydown", function (event) {
                if (event.key === "Escape" && button.getAttribute("aria-expanded") === "true") {
                    closeNavigation(button, container);
                    button.focus();
                }
            });
        });
    });
}());
