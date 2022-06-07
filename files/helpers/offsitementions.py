from flask import g
import itertools
import requests
import files.helpers.const as const
from files.classes.user import User
from files.classes.comment import Comment
from files.classes.notifications import Notification

# https://api.pushshift.io/meta provides key server_ratelimit_per_minute
# At time of writing, the ratelimit is 120 req/min. We get nowhere near this 
# with current keyword quantities. If this ever changes, consider reading the 
# value from /meta and doing a random selection of keywords.

def offsite_mentions_task():
	if const.REDDIT_NOTIFS_SITE:
		# Site-specific logic: send to JL1+, except on PCM JL3+
		jl_min = 3 if const.SITE_NAME == 'PCM' else 1
		row_send_to = g.db.query(User.id).filter(User.admin_level >= jl_min).all()
		send_to = [x[0] for x in row_send_to]

		site_mentions = get_mentions(const.REDDIT_NOTIFS_SITE)
		notify_mentions(send_to, site_mentions)

	if const.REDDIT_NOTIFS_USERS:
		for query, send_user in const.REDDIT_NOTIFS_USERS.items():
			if not send_user: continue

			user_mentions = get_mentions([query])
			notify_mentions([send_user], user_mentions, mention_str='mention of you')

def get_mentions(queries):
	kinds = ['submission', 'comment']
	mentions = []
	for kind, query in itertools.product(kinds, queries):
		try:
			data = requests.get(f'https://api.pushshift.io/reddit/{kind}/search'
				+ f'?html_decode=true&q={query}&size=1', timeout=5).json()['data']
		except: break

		for i in data: 
			# Special case: PokemonGoRaids says 'Marsey' a lot unrelated to us.
			if i['subreddit'] == 'PokemonGoRaids': continue

			mentions.append(i['permalink'])

	return mentions

def notify_mentions(send_to, mentions, mention_str='site mention'):
	for m in mentions:
		notif_text = f'<p>New {mention_str}: <a href="https://old.reddit.com{m}' \
			f'?context=89" rel="nofollow noopener noreferrer" target="_blank">' \
			f'https://old.reddit.com{m}?context=89</a></p>'

		existing_comment = g.db.query(Comment.id).filter_by(
			author_id=const.NOTIFICATIONS_ID, 
			parent_submission=None, 
			body_html=notif_text).one_or_none()
		if existing_comment: break

		new_comment = Comment(
						author_id=const.NOTIFICATIONS_ID,
						parent_submission=None,
						body_html=notif_text,
						distinguish_level=6)
		g.db.add(new_comment)
		g.db.flush()
		new_comment.top_comment_id = new_comment.id

		for user_id in send_to:
			notif = Notification(comment_id=new_comment.id, user_id=user_id)
			g.db.add(notif)

	g.db.commit()

