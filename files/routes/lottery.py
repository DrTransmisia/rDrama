from files.__main__ import app, limiter
from files.helpers.wrappers import *
from files.helpers.alerts import *
from files.helpers.get import *
from files.helpers.const import *
from files.helpers.wrappers import *
from files.helpers.lottery import *


@app.post("/lottery/end")
@admin_level_required(3)
@lottery_required
def lottery_end(v):
    success, message = end_lottery_session()
    return {"message": message} if success else {"error": message}


@app.post("/lottery/start")
@admin_level_required(3)
@lottery_required
def lottery_start(v):
    start_new_lottery_session()
    return {"message": "Lottery started."}


@app.post("/lottery/buy")
@limiter.limit("1/second;30/minute;200/hour;1000/day")
@auth_required
@lottery_required
def lottery_buy(v):
    success, message = purchase_lottery_ticket(v)
    lottery, participants = get_active_lottery_stats()

    if success:
        return {"message": message, "stats": {"user": v.lottery_stats, "lottery": lottery, "participants": participants}}
    else:
        return {"error": message, "stats": {"user": v.lottery_stats, "lottery": lottery, "participants": participants}}


@app.get("/lottery/active")
@limiter.limit("1/second;30/minute;200/hour;1000/day")
@auth_required
@lottery_required
def lottery_active(v):
    lottery, participants = get_active_lottery_stats()

    return {"message": "", "stats": {"user": v.lottery_stats, "lottery": lottery, "participants": participants}}
