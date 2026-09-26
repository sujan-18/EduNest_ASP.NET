(function () {
    "use strict";

    function initializeQuizFilters() {
        var cards = Array.prototype.slice.call(document.querySelectorAll(".quiz-center-card"));
        var subject = document.getElementById("quizSubjectFilter");
        var course = document.getElementById("quizCourseFilter");
        var count = document.getElementById("quizFilterCount");
        var empty = document.getElementById("noQuizMatches");
        if (!cards.length || !subject || !course || !count || !empty) return;

        var courseNames = {};
        cards.forEach(function (card) { courseNames[card.getAttribute("data-quiz-course")] = true; });
        Object.keys(courseNames).sort().forEach(function (name) {
            var option = document.createElement("option");
            option.value = name;
            option.textContent = name;
            course.appendChild(option);
        });

        function filter() {
            var selectedSubject = subject.value.toLocaleLowerCase();
            var selectedCourse = course.value.toLocaleLowerCase();
            var visible = 0;
            cards.forEach(function (card) {
                var matches = (!selectedSubject || card.getAttribute("data-quiz-category").toLocaleLowerCase() === selectedSubject) &&
                    (!selectedCourse || card.getAttribute("data-quiz-course").toLocaleLowerCase() === selectedCourse);
                card.hidden = !matches;
                if (matches) visible += 1;
            });
            count.textContent = visible + (visible === 1 ? " quiz" : " quizzes");
            empty.hidden = visible !== 0;
        }

        subject.addEventListener("change", function () {
            course.value = "";
            filter();
        });
        course.addEventListener("change", filter);
        filter();
    }

    if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", initializeQuizFilters);
    else initializeQuizFilters();
}());
