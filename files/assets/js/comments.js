function timestamp(str, ti) {
    date = new Date(ti*1000);
    document.getElementById(str).setAttribute("data-bs-original-title", date.toString());
};

function collapse_comment(comment_id) {
    const comment = `comment-${comment_id}`;
    const closed = comment.classList.toggle("collapsed");
    const top = comment.getBoundingClientRect().y;

    const text = document.getElementById(`comment-text-${comment_id}`)
    const actions = document.getElementById(`comment-${comment_id}-actions`)
    const repliesOf = document.getElementById(`replies-of-${comment_id}`)

    const arr = [text, actions, repliesOf];

    arr.map(x => x.classList.toggle('hidden')); // hide comment elements
    comment.classList.toggle('items-center opacity-50'); // apply flex alignment and opacity to comment parent wrapping div

    if (closed && top < 0) {
        comment.scrollIntoView()
        window.scrollBy(0, - 100)
    }
};