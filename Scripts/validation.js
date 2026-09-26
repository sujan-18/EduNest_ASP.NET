// ===================================================
// EduNest - Client-side form validation
// Runs before postback; server-side validation in the
// code-behind of each page is the authoritative check.
// ===================================================

// Generic helper used by several pages: shows an inline error message
// under the given input element without a full postback.
function showFieldError(inputId, message) {
    var input = document.getElementById(inputId);
    if (!input) return;
    var next = input.nextElementSibling;
    if (!next || !next.classList.contains('js-error')) {
        next = document.createElement('span');
        next.className = 'field-error js-error';
        input.parentNode.insertBefore(next, input.nextSibling);
    }
    next.textContent = message;
}

function clearFieldError(inputId) {
    var input = document.getElementById(inputId);
    if (!input) return;
    var next = input.nextElementSibling;
    if (next && next.classList.contains('js-error')) {
        next.textContent = '';
    }
}

// Basic email format check re-used by Register.aspx and ManageUsers.aspx
function isValidEmail(value) {
    var re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return re.test(value);
}

// Password strength check re-used by Register.aspx
function isStrongPassword(value) {
    // At least 8 characters, one letter, one number
    var re = /^(?=.*[A-Za-z])(?=.*\d).{8,}$/;
    return re.test(value);
}
