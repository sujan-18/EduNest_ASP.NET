(function () {
    "use strict";

    document.addEventListener("DOMContentLoaded", function () {
        var grid = document.getElementById("courseGrid");
        if (!grid) return;

        var cards = Array.prototype.slice.call(grid.querySelectorAll(".catalog-course-card"));
        var search = document.getElementById("courseSearch");
        var category = document.getElementById("categoryFilter");
        var level = document.getElementById("levelFilter");
        var sort = document.getElementById("courseSort");
        var clear = document.getElementById("clearCourseFilters");
        var resultCount = document.getElementById("courseResultCount");
        var emptyState = document.getElementById("noCourseMatches");

        function applyFilters() {
            var query = search.value.trim().toLocaleLowerCase();
            var selectedCategory = category.value.toLocaleLowerCase();
            var selectedLevel = level.value.toLocaleLowerCase();
            var visibleCount = 0;

            cards.forEach(function (card) {
                var matches = (!query || card.textContent.toLocaleLowerCase().indexOf(query) >= 0) &&
                    (!selectedCategory || card.dataset.courseCategory.toLocaleLowerCase() === selectedCategory) &&
                    (!selectedLevel || card.dataset.courseLevel.toLocaleLowerCase() === selectedLevel);
                card.hidden = !matches;
                if (matches) visibleCount++;
            });

            cards.sort(function (left, right) {
                if (sort.value === "shortest" || sort.value === "longest") {
                    var delta = Number(left.dataset.courseHours) - Number(right.dataset.courseHours);
                    return sort.value === "shortest" ? delta : -delta;
                }
                var nameDelta = left.dataset.courseTitle.localeCompare(right.dataset.courseTitle);
                return sort.value === "title-desc" ? -nameDelta : nameDelta;
            }).forEach(function (card) { grid.appendChild(card); });

            resultCount.textContent = "Showing " + visibleCount + " of " + cards.length + " courses";
            emptyState.hidden = visibleCount !== 0;
        }

        search.addEventListener("input", applyFilters);
        category.addEventListener("change", applyFilters);
        level.addEventListener("change", applyFilters);
        sort.addEventListener("change", applyFilters);
        clear.addEventListener("click", function () {
            search.value = "";
            category.value = "";
            level.value = "";
            sort.value = "title";
            applyFilters();
            search.focus();
        });
        applyFilters();
    });
}());
