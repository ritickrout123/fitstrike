document.addEventListener('DOMContentLoaded', () => {
    const navItems = document.querySelectorAll('.nav-item');
    const views = document.querySelectorAll('.view');

    // Navigation Switch Logic
    navItems.forEach(item => {
        item.addEventListener('click', (e) => {
            e.preventDefault();
            const targetId = item.getAttribute('data-target');
            
            // Remove active classes
            navItems.forEach(nav => nav.classList.remove('active'));
            views.forEach(view => view.classList.remove('active-view'));
            
            // Add active class to clicked nav and target view
            item.classList.add('active');
            document.getElementById(targetId).classList.add('active-view');
        });
    });

    // Re-trigger progress ring animation on view switch (Optional helper for flair)
    // Could track when view-dashboard becomes active.
});
