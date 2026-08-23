def bulletin(c, ctx):
    headline = str(ctx.inputs.get("headline", "EGRESS DOOR RULE UPDATED"))
    detail = str(ctx.inputs.get("detail", "REVIEW BEFORE NEXT INSPECTION"))
    severity = str(ctx.inputs.get("severity", "WARNING"))
    jurisdiction = str(ctx.inputs.get("jurisdiction", "LOCAL"))
    audience = str(ctx.inputs.get("audience", "ALL"))
    source = str(ctx.inputs.get("source", "OFFICIAL SOURCE"))
    showtimestamp = ctx.inputs.get("showtimestamp", True)
    timestamputc = ctx.inputs.get("timestamputc", True)
    localclock = ctx.inputs.get("localclock", False)
    clocktimezone = str(ctx.inputs.get("clocktimezone", "America/Indiana/Indianapolis"))
    timestamp = str(ctx.inputs.get("timestamp", "MAN"))
    states = str(ctx.inputs.get("states", "Indiana"))
    statefilter = ",".join(states.split(",")[:5])
    feedurl = str(ctx.inputs.get("feedurl", ""))
    apikey = str(ctx.inputs.get("apikey", ""))

    if feedurl:
        headers = {}
        if apikey:
            headers = {"Authorization": "Bearer " + apikey}
        resp = http.get(feedurl, headers=headers, params={"states": statefilter}, ttl_seconds=300)
        if resp["status_code"] == 200:
            data = resp["json"]
            headline = str(data.get("headline", headline))
            detail = str(data.get("detail", detail))
            severity = str(data.get("level", severity))
            jurisdiction = str(data.get("jurisdiction", jurisdiction))
            audience = str(data.get("audience", audience))
            source = str(data.get("source", source))
            timestamp = str(data.get("display_timestamp", timestamp))
            timestamputc = data.get("timestamp_utc", timestamputc)
        else:
            timestamp = "ERROR"

    localclock = str(localclock).upper() != "FALSE" and str(localclock) != "0" and str(localclock).upper() != "NO"
    if localclock:
        clockresp = http.get(
            "https://timeapi.io/api/TimeZone/zone",
            params={"timeZone": clocktimezone},
            ttl_seconds=3600,
        )
        offsetseconds = None
        if clockresp["status_code"] == 200:
            clockdata = clockresp["json"]
            if clockdata:
                offsetseconds = clockdata.get("currentUtcOffset", {}).get("seconds", None)
        if offsetseconds != None:
            localseconds = (ctx.now.unix + int(offsetseconds)) % 86400
            localhour = localseconds // 3600
            localminute = (localseconds % 3600) // 60
            timestamp = ("0" + str(localhour))[-2:] + ":" + ("0" + str(localminute))[-2:]
        else:
            timestamp = "TZERR"
        timestamputc = False

    headline = headline.upper()
    detail = detail.upper()
    severity = severity.upper()
    jurisdiction = jurisdiction.upper()
    audience = audience.upper()
    source = source.upper()
    timestamp = timestamp.upper()
    showtimestamp = str(showtimestamp).upper() != "FALSE" and str(showtimestamp) != "0" and str(showtimestamp).upper() != "NO"
    timestamputc = str(timestamputc).upper() != "FALSE" and str(timestamputc) != "0" and str(timestamputc).upper() != "NO"
    if not timestamputc and timestamp[-1:] == "Z":
        timestamp = timestamp[:-1]
    timestampcolor = "#7F98A8"
    if timestamp == "ERROR" or timestamp == "TZERR":
        timestampcolor = "#FF3030"

    accent = "#FFB000"
    if severity == "CRITICAL":
        accent = "#FF3030"
    elif severity == "INFO":
        accent = "#00CFFF"

    c.fill("#020406")
    c.rect(0, 0, 191, 31, outline="#294052")
    c.rect(0, 0, 3, 31, fill=accent)
    c.text(("CODETRACK / " + audience)[:21], 7, 1, font="4x5", color="#9CB3C4")
    if showtimestamp:
        c.text(timestamp[:5], 119, 1, font="4x5", color=timestampcolor)
    c.rect(148, 0, 190, 7, fill=accent)
    c.text(severity[:8], 151, 1, font="4x5", color="#000000")
    c.hline(6, 190, 8, color="#294052")
    c.text(headline[:30], 7, 11, font="5x7", color="#FFFFFF")
    c.text((jurisdiction[:8] + " | " + detail[:15] + " | " + source[:8])[:36], 7, 22, font="4x5", color=accent)


def adoption(c, ctx):
    adoptioncode = str(ctx.inputs.get("adoptioncode", "2024 IBC"))
    adoptionphase = str(ctx.inputs.get("adoptionphase", "ADOPTED"))
    adoptiondate = str(ctx.inputs.get("adoptiondate", "2026-10-01"))
    adoptiondays = str(ctx.inputs.get("adoptiondays", "42"))
    proposalimpact = str(ctx.inputs.get("proposalimpact", "ROUTINE"))
    proposalsummary = str(ctx.inputs.get("proposalsummary", "AFFECTS LIFE SAFETY"))
    advocacyask = str(ctx.inputs.get("advocacyask", "SUBMIT COMMENTS"))
    policyview = str(ctx.inputs.get("policyview", "RULEMAKING"))
    ruleid = str(ctx.inputs.get("ruleid", "LSA 26-101"))
    ruleagency = str(ctx.inputs.get("ruleagency", "STATE FIRE MARSHAL"))
    rulestage = str(ctx.inputs.get("rulestage", "COMMENTS"))
    ruledate = str(ctx.inputs.get("ruledate", "2026-09-30"))
    ruledays = str(ctx.inputs.get("ruledays", "40"))
    ruleimpact = str(ctx.inputs.get("ruleimpact", "SUBSTANTIAL"))
    rulesummary = str(ctx.inputs.get("rulesummary", "UPDATES EGRESS REQUIREMENTS"))
    ruleaction = str(ctx.inputs.get("ruleaction", "SUBMIT COMMENTS"))
    showtimestamp = ctx.inputs.get("showtimestamp", True)
    timestamputc = ctx.inputs.get("timestamputc", True)
    localclock = ctx.inputs.get("localclock", False)
    clocktimezone = str(ctx.inputs.get("clocktimezone", "America/Indiana/Indianapolis"))
    timestamp = str(ctx.inputs.get("timestamp", "MAN"))
    approvedcolor = str(ctx.inputs.get("approvedcolor", "#25E06F"))
    rejectedcolor = str(ctx.inputs.get("rejectedcolor", "#FF3030"))
    strickencolor = str(ctx.inputs.get("strickencolor", "#D8DEE9"))
    deferredcolor = str(ctx.inputs.get("deferredcolor", "#FF4FD8"))
    tabledcolor = str(ctx.inputs.get("tabledcolor", "#FFB000"))
    amendedcolor = str(ctx.inputs.get("amendedcolor", "#00D9FF"))
    jurisdiction = str(ctx.inputs.get("jurisdiction", "LOCAL"))
    states = str(ctx.inputs.get("states", "Indiana"))
    statefilter = ",".join(states.split(",")[:5])
    feedurl = str(ctx.inputs.get("feedurl", ""))
    apikey = str(ctx.inputs.get("apikey", ""))

    if feedurl:
        headers = {}
        if apikey:
            headers = {"Authorization": "Bearer " + apikey}
        resp = http.get(feedurl, headers=headers, params={"states": statefilter}, ttl_seconds=300)
        if resp["status_code"] == 200:
            data = resp["json"]
            adoptioncode = str(data.get("adoption_code", adoptioncode))
            adoptionphase = str(data.get("adoption_phase", adoptionphase))
            adoptiondate = str(data.get("adoption_date", adoptiondate))
            adoptiondays = str(data.get("adoption_days", adoptiondays))
            proposalimpact = str(data.get("proposal_impact", proposalimpact))
            proposalsummary = str(data.get("proposal_summary", proposalsummary))
            advocacyask = str(data.get("advocacy_ask", advocacyask))
            feedpolicyview = str(data.get("policy_view", ""))
            if feedpolicyview:
                policyview = feedpolicyview
            elif str(data.get("rulemaking_id", "")):
                policyview = "RULEMAKING"
            elif str(data.get("adoption_code", "")):
                policyview = "ADOPTION"
            ruleid = str(data.get("rulemaking_id", ruleid))
            ruleagency = str(data.get("rulemaking_agency", ruleagency))
            rulestage = str(data.get("rulemaking_stage", rulestage))
            ruledate = str(data.get("rulemaking_date", ruledate))
            ruledays = str(data.get("rulemaking_days", ruledays))
            ruleimpact = str(data.get("rulemaking_impact", ruleimpact))
            rulesummary = str(data.get("rulemaking_summary", rulesummary))
            ruleaction = str(data.get("rulemaking_action", ruleaction))
            jurisdiction = str(data.get("jurisdiction", jurisdiction))
            timestamp = str(data.get("display_timestamp", timestamp))
            timestamputc = data.get("timestamp_utc", timestamputc)
        else:
            timestamp = "ERROR"

    localclock = str(localclock).upper() != "FALSE" and str(localclock) != "0" and str(localclock).upper() != "NO"
    if localclock:
        clockresp = http.get(
            "https://timeapi.io/api/TimeZone/zone",
            params={"timeZone": clocktimezone},
            ttl_seconds=3600,
        )
        offsetseconds = None
        if clockresp["status_code"] == 200:
            clockdata = clockresp["json"]
            if clockdata:
                offsetseconds = clockdata.get("currentUtcOffset", {}).get("seconds", None)
        if offsetseconds != None:
            localseconds = (ctx.now.unix + int(offsetseconds)) % 86400
            localhour = localseconds // 3600
            localminute = (localseconds % 3600) // 60
            timestamp = ("0" + str(localhour))[-2:] + ":" + ("0" + str(localminute))[-2:]
        else:
            timestamp = "TZERR"
        timestamputc = False

    adoptioncode = adoptioncode.upper()
    adoptionphase = adoptionphase.upper()
    adoptiondate = adoptiondate.upper()
    adoptiondays = adoptiondays.upper()
    proposalimpact = proposalimpact.upper()
    proposalsummary = proposalsummary.upper()
    advocacyask = advocacyask.upper()
    policyview = policyview.upper()
    ruleid = ruleid.upper()
    ruleagency = ruleagency.upper()
    rulestage = rulestage.upper()
    ruledate = ruledate.upper()
    ruledays = ruledays.upper()
    ruleimpact = ruleimpact.upper()
    rulesummary = rulesummary.upper()
    ruleaction = ruleaction.upper()
    jurisdiction = jurisdiction.upper()
    timestamp = timestamp.upper()
    showtimestamp = str(showtimestamp).upper() != "FALSE" and str(showtimestamp) != "0" and str(showtimestamp).upper() != "NO"
    timestamputc = str(timestamputc).upper() != "FALSE" and str(timestamputc) != "0" and str(timestamputc).upper() != "NO"
    if not timestamputc and timestamp[-1:] == "Z":
        timestamp = timestamp[:-1]
    timestampcolor = "#6F8A96"
    if timestamp == "ERROR" or timestamp == "TZERR":
        timestampcolor = rejectedcolor

    trackcode = adoptioncode
    trackstage = adoptionphase
    trackdate = adoptiondate
    trackdays = adoptiondays
    trackimpact = proposalimpact
    tracksummary = proposalsummary
    trackaction = advocacyask
    trackarea = jurisdiction
    is_rulemaking = policyview == "RULEMAKING"
    if is_rulemaking:
        trackcode = ruleid
        trackstage = rulestage
        trackdate = ruledate
        trackdays = ruledays
        trackimpact = ruleimpact
        tracksummary = rulesummary
        trackaction = ruleaction
        trackarea = ruleagency

    if not trackdays:
        trackdays = "?"
    due_label = "D-" + trackdays
    overdue = False
    if trackdays == "0":
        due_label = "DUE"
        overdue = True
    elif trackdays[:1] == "-":
        due_label = trackdays[1:5] + "D LATE"
        overdue = True

    accent = "#00D9FF"
    policy_alert = False
    if trackstage == "ADOPTED" or trackstage == "HEARING" or trackstage == "COMMITTEE" or trackstage == "COMMENTS":
        accent = "#FFB000"
    elif trackstage == "EFFECTIVE" or trackstage == "FINAL":
        accent = "#25E06F"
    elif trackstage == "APPROVED":
        accent = approvedcolor
        policy_alert = True
    elif trackstage == "APPROVED W/ AMENDMENTS":
        accent = amendedcolor
        policy_alert = True
    elif trackstage == "REJECTED":
        accent = rejectedcolor
        policy_alert = True
    elif trackstage == "STRICKEN":
        accent = strickencolor
        policy_alert = True
    elif trackstage == "TABLED":
        accent = tabledcolor
        policy_alert = True
    elif trackstage == "DEFERRED":
        accent = deferredcolor
        policy_alert = True
    elif trackstage == "PROPOSED" and trackimpact == "SUBSTANTIAL":
        accent = "#FFB000"
    if overdue:
        accent = rejectedcolor

    page_title = "POLICY / ADOPTION"
    main_text = trackcode + " | " + due_label
    stage_badge = trackstage
    if trackstage == "APPROVED W/ AMENDMENTS":
        stage_badge = "AMENDED"
    if is_rulemaking:
        page_title = "RULEMAKING TRACK"
        if trackimpact == "SUBSTANTIAL":
            page_title = "SUBSTANTIAL RULE"
    if policy_alert:
        page_title = "POLICY ALERT"
        if is_rulemaking:
            page_title = "RULE ALERT"
        main_text = stage_badge + " | " + due_label + " | " + trackcode
    if trackstage == "APPROVED":
        page_title = "POLICY UPDATE"
        if is_rulemaking:
            page_title = "RULE APPROVED"
    elif trackstage == "APPROVED W/ AMENDMENTS":
        page_title = "APPROVED AMENDED"
    elif trackstage == "STRICKEN":
        page_title = "POLICY STRICKEN"
        if is_rulemaking:
            page_title = "RULE STRICKEN"
    elif trackstage == "PROPOSED":
        page_title = "PROPOSAL INFO"
        main_text = trackstage + " | " + due_label + " | " + trackcode
        if trackimpact == "SUBSTANTIAL":
            page_title = "SUBSTANTIAL PROPOSAL"

    c.fill("#02060A")
    c.rect(0, 0, 191, 31, outline="#174B5D")
    c.rect(0, 0, 3, 31, fill=accent)
    c.text(page_title, 7, 1, font="4x5", color="#AFC7D0")
    if showtimestamp:
        c.text(timestamp[:5], 110, 1, font="4x5", color=timestampcolor)
    c.rect(139, 0, 190, 7, fill=accent)
    c.text(stage_badge[:9], 143, 1, font="4x5", color="#000000")
    c.hline(6, 190, 8, color="#174B5D")
    if trackimpact == "SUBSTANTIAL" and (trackstage == "PROPOSED" or is_rulemaking):
        c.text((trackcode + " | " + due_label)[:36], 7, 10, font="4x5", color="#FFFFFF")
        c.text(tracksummary[:36], 7, 17, font="4x5", color=accent)
        c.text((trackdate[:10] + " | " + trackarea[:8] + " | " + trackaction[:9])[:36], 7, 24, font="4x5", color="#AFC7D0")
    else:
        c.text(main_text[:30], 7, 11, font="5x7", color="#FFFFFF")
        c.text((trackdate[:10] + " | " + trackarea[:8] + " | " + trackaction[:9])[:36], 7, 22, font="4x5", color=accent)


def standards(c, ctx):
    standardname = str(ctx.inputs.get("standardname", "NFPA 101"))
    edition = str(ctx.inputs.get("edition", "2024"))
    standardupdate = str(ctx.inputs.get("standardupdate", "TIA AND ERRATA WATCH"))
    effective = str(ctx.inputs.get("effective", "2026-09-01"))
    source = str(ctx.inputs.get("source", "OFFICIAL SOURCE"))
    showtimestamp = ctx.inputs.get("showtimestamp", True)
    timestamputc = ctx.inputs.get("timestamputc", True)
    localclock = ctx.inputs.get("localclock", False)
    clocktimezone = str(ctx.inputs.get("clocktimezone", "America/Indiana/Indianapolis"))
    timestamp = str(ctx.inputs.get("timestamp", "MAN"))
    states = str(ctx.inputs.get("states", "Indiana"))
    statefilter = ",".join(states.split(",")[:5])
    feedurl = str(ctx.inputs.get("feedurl", ""))
    apikey = str(ctx.inputs.get("apikey", ""))

    if feedurl:
        headers = {}
        if apikey:
            headers = {"Authorization": "Bearer " + apikey}
        resp = http.get(feedurl, headers=headers, params={"states": statefilter}, ttl_seconds=300)
        if resp["status_code"] == 200:
            data = resp["json"]
            standardname = str(data.get("standard", standardname))
            edition = str(data.get("edition", edition))
            standardupdate = str(data.get("update", standardupdate))
            effective = str(data.get("effective", effective))
            source = str(data.get("source", source))
            timestamp = str(data.get("display_timestamp", timestamp))
            timestamputc = data.get("timestamp_utc", timestamputc)
        else:
            timestamp = "ERROR"

    localclock = str(localclock).upper() != "FALSE" and str(localclock) != "0" and str(localclock).upper() != "NO"
    if localclock:
        clockresp = http.get(
            "https://timeapi.io/api/TimeZone/zone",
            params={"timeZone": clocktimezone},
            ttl_seconds=3600,
        )
        offsetseconds = None
        if clockresp["status_code"] == 200:
            clockdata = clockresp["json"]
            if clockdata:
                offsetseconds = clockdata.get("currentUtcOffset", {}).get("seconds", None)
        if offsetseconds != None:
            localseconds = (ctx.now.unix + int(offsetseconds)) % 86400
            localhour = localseconds // 3600
            localminute = (localseconds % 3600) // 60
            timestamp = ("0" + str(localhour))[-2:] + ":" + ("0" + str(localminute))[-2:]
        else:
            timestamp = "TZERR"
        timestamputc = False

    standardname = standardname.upper()
    edition = edition.upper()
    standardupdate = standardupdate.upper()
    effective = effective.upper()
    source = source.upper()
    timestamp = timestamp.upper()
    showtimestamp = str(showtimestamp).upper() != "FALSE" and str(showtimestamp) != "0" and str(showtimestamp).upper() != "NO"
    timestamputc = str(timestamputc).upper() != "FALSE" and str(timestamputc) != "0" and str(timestamputc).upper() != "NO"
    if not timestamputc and timestamp[-1:] == "Z":
        timestamp = timestamp[:-1]
    timestampcolor = "#6F8A96"
    if timestamp == "ERROR" or timestamp == "TZERR":
        timestampcolor = "#FF3030"

    c.fill("#02060A")
    c.rect(0, 0, 191, 31, outline="#174B5D")
    c.rect(0, 0, 3, 31, fill="#00D9FF")
    c.text("STANDARDS WATCH", 7, 1, font="4x5", color="#00D9FF")
    if showtimestamp:
        c.text(timestamp[:5], 115, 1, font="4x5", color=timestampcolor)
    c.text("VERIFIED", 150, 1, font="4x5", color="#8BFFB0")
    c.hline(6, 190, 8, color="#174B5D")
    c.text((standardname + " " + edition + ": " + standardupdate)[:30], 7, 11, font="5x7", color="#FFFFFF")
    c.text(("EFF " + effective + " | " + source)[:36], 7, 22, font="4x5", color="#A9C9D3")


def compliance(c, ctx):
    openitems = str(ctx.inputs.get("openitems", "3"))
    inspections = str(ctx.inputs.get("inspections", "1"))
    risk = str(ctx.inputs.get("risk", "MEDIUM"))
    nextinspection = str(ctx.inputs.get("nextinspection", "2026-09-15"))
    complianceview = str(ctx.inputs.get("complianceview", "VARIANCE"))
    varianceid = str(ctx.inputs.get("varianceid", "VAR-2026-014"))
    varianceproject = str(ctx.inputs.get("varianceproject", "BUILDING A EGRESS"))
    variancestatus = str(ctx.inputs.get("variancestatus", "HEARING"))
    variancedate = str(ctx.inputs.get("variancedate", "2026-09-22"))
    variancedays = str(ctx.inputs.get("variancedays", "32"))
    varianceboard = str(ctx.inputs.get("varianceboard", "FIRE PREVENTION"))
    varianceowner = str(ctx.inputs.get("varianceowner", "FACILITIES"))
    varianceconditions = str(ctx.inputs.get("varianceconditions", "2 CONDITIONS OPEN"))
    variancepriority = str(ctx.inputs.get("variancepriority", "HIGH"))
    showtimestamp = ctx.inputs.get("showtimestamp", True)
    timestamputc = ctx.inputs.get("timestamputc", True)
    localclock = ctx.inputs.get("localclock", False)
    clocktimezone = str(ctx.inputs.get("clocktimezone", "America/Indiana/Indianapolis"))
    timestamp = str(ctx.inputs.get("timestamp", "MAN"))
    approvedcolor = str(ctx.inputs.get("approvedcolor", "#25E06F"))
    rejectedcolor = str(ctx.inputs.get("rejectedcolor", "#FF3030"))
    strickencolor = str(ctx.inputs.get("strickencolor", "#D8DEE9"))
    deferredcolor = str(ctx.inputs.get("deferredcolor", "#FF4FD8"))
    tabledcolor = str(ctx.inputs.get("tabledcolor", "#FFB000"))
    amendedcolor = str(ctx.inputs.get("amendedcolor", "#00D9FF"))
    states = str(ctx.inputs.get("states", "Indiana"))
    statefilter = ",".join(states.split(",")[:5])
    feedurl = str(ctx.inputs.get("feedurl", ""))
    apikey = str(ctx.inputs.get("apikey", ""))

    if feedurl:
        headers = {}
        if apikey:
            headers = {"Authorization": "Bearer " + apikey}
        resp = http.get(feedurl, headers=headers, params={"states": statefilter}, ttl_seconds=300)
        if resp["status_code"] == 200:
            data = resp["json"]
            openitems = str(data.get("open_items", openitems))
            inspections = str(data.get("inspections", inspections))
            risk = str(data.get("risk", risk))
            nextinspection = str(data.get("next_inspection", nextinspection))
            feedcomplianceview = str(data.get("compliance_view", ""))
            if feedcomplianceview:
                complianceview = feedcomplianceview
            elif str(data.get("variance_id", "")):
                complianceview = "VARIANCE"
            elif str(data.get("open_items", "")) or str(data.get("inspections", "")) or str(data.get("risk", "")):
                complianceview = "COMPLIANCE"
            varianceid = str(data.get("variance_id", varianceid))
            varianceproject = str(data.get("variance_project", varianceproject))
            variancestatus = str(data.get("variance_status", variancestatus))
            variancedate = str(data.get("variance_date", variancedate))
            variancedays = str(data.get("variance_days", variancedays))
            varianceboard = str(data.get("variance_board", varianceboard))
            varianceowner = str(data.get("variance_owner", varianceowner))
            varianceconditions = str(data.get("variance_conditions", varianceconditions))
            variancepriority = str(data.get("variance_priority", variancepriority))
            timestamp = str(data.get("display_timestamp", timestamp))
            timestamputc = data.get("timestamp_utc", timestamputc)
        else:
            timestamp = "ERROR"

    localclock = str(localclock).upper() != "FALSE" and str(localclock) != "0" and str(localclock).upper() != "NO"
    if localclock:
        clockresp = http.get(
            "https://timeapi.io/api/TimeZone/zone",
            params={"timeZone": clocktimezone},
            ttl_seconds=3600,
        )
        offsetseconds = None
        if clockresp["status_code"] == 200:
            clockdata = clockresp["json"]
            if clockdata:
                offsetseconds = clockdata.get("currentUtcOffset", {}).get("seconds", None)
        if offsetseconds != None:
            localseconds = (ctx.now.unix + int(offsetseconds)) % 86400
            localhour = localseconds // 3600
            localminute = (localseconds % 3600) // 60
            timestamp = ("0" + str(localhour))[-2:] + ":" + ("0" + str(localminute))[-2:]
        else:
            timestamp = "TZERR"
        timestamputc = False

    openitems = openitems.upper()
    inspections = inspections.upper()
    risk = risk.upper()
    nextinspection = nextinspection.upper()
    complianceview = complianceview.upper()
    varianceid = varianceid.upper()
    varianceproject = varianceproject.upper()
    variancestatus = variancestatus.upper()
    variancedate = variancedate.upper()
    variancedays = variancedays.upper()
    varianceboard = varianceboard.upper()
    varianceowner = varianceowner.upper()
    varianceconditions = varianceconditions.upper()
    variancepriority = variancepriority.upper()
    timestamp = timestamp.upper()
    showtimestamp = str(showtimestamp).upper() != "FALSE" and str(showtimestamp) != "0" and str(showtimestamp).upper() != "NO"
    timestamputc = str(timestamputc).upper() != "FALSE" and str(timestamputc) != "0" and str(timestamputc).upper() != "NO"
    if not timestamputc and timestamp[-1:] == "Z":
        timestamp = timestamp[:-1]
    timestampcolor = "#718B7D"
    if timestamp == "ERROR" or timestamp == "TZERR":
        timestampcolor = rejectedcolor

    accent = "#FFB000"
    if risk == "HIGH":
        accent = "#FF3030"
    elif risk == "LOW":
        accent = "#25E06F"

    c.fill("#030504")
    c.rect(0, 0, 191, 31, outline="#294238")
    if complianceview == "VARIANCE":
        if not variancedays:
            variancedays = "?"
        due_label = "D-" + variancedays
        overdue = False
        if variancedays == "0":
            due_label = "DUE"
            overdue = True
        elif variancedays[:1] == "-":
            due_label = variancedays[1:5] + "D LATE"
            overdue = True

        accent = "#00D9FF"
        if variancepriority == "HIGH" or variancestatus == "HEARING" or variancestatus == "CONTINUED" or variancestatus == "CONDITIONAL":
            accent = "#FFB000"
        if variancestatus == "APPROVED":
            accent = approvedcolor
        elif variancestatus == "APPROVED W/ AMENDMENTS":
            accent = amendedcolor
        elif variancestatus == "REJECTED" or variancestatus == "EXPIRED":
            accent = rejectedcolor
        elif variancestatus == "STRICKEN":
            accent = strickencolor
        elif variancestatus == "TABLED":
            accent = tabledcolor
        elif variancestatus == "DEFERRED":
            accent = deferredcolor
        if overdue:
            accent = rejectedcolor

        c.rect(0, 0, 3, 31, fill=accent)
        c.text("VARIANCE TRACK", 7, 1, font="4x5", color="#B3C7BC")
        if showtimestamp:
            c.text(timestamp[:5], 110, 1, font="4x5", color=timestampcolor)
        c.rect(139, 0, 190, 7, fill=accent)
        variancebadge = variancestatus
        if variancestatus == "APPROVED W/ AMENDMENTS":
            variancebadge = "AMENDED"
        c.text(variancebadge[:9], 143, 1, font="4x5", color="#000000")
        c.hline(6, 190, 8, color="#294238")
        c.text((varianceid + " | " + variancedate[:10] + " | " + due_label)[:36], 7, 10, font="4x5", color="#FFFFFF")
        c.text(varianceproject[:36], 7, 17, font="4x5", color=accent)
        c.text((varianceboard[:10] + " | " + varianceowner[:8] + " | " + varianceconditions[:12])[:36], 7, 24, font="4x5", color="#B3C7BC")
    else:
        c.rect(0, 0, 3, 31, fill=accent)
        compliance_title = "LIFE SAFETY MONITOR"
        if showtimestamp:
            compliance_title = "COMPLIANCE"
        c.text(compliance_title, 7, 1, font="4x5", color="#B3C7BC")
        if showtimestamp:
            c.text(timestamp[:5], 87, 1, font="4x5", color=timestampcolor)
        c.text(("NEXT " + nextinspection)[:15], 117, 1, font="4x5", color=accent)
        c.hline(6, 190, 8, color="#294238")
        c.vline(64, 10, 29, color="#294238")
        c.vline(126, 10, 29, color="#294238")
        c.text("OPEN", 10, 11, font="4x5", color="#9DB3A7")
        c.text(openitems[:5], 10, 19, font="7x12", color="#FFFFFF")
        c.text("DUE", 72, 11, font="4x5", color="#9DB3A7")
        c.text(inspections[:5], 72, 19, font="7x12", color="#FFFFFF")
        c.text("RISK", 134, 11, font="4x5", color="#9DB3A7")
        c.text(risk[:7], 134, 21, font="5x7", color=accent)


def inspection(c, ctx):
    inspectiontype = str(ctx.inputs.get("inspectiontype", "ANNUAL FIRE"))
    inspectionarea = str(ctx.inputs.get("inspectionarea", "BUILDING A"))
    inspectiondate = str(ctx.inputs.get("inspectiondate", "2026-09-15"))
    inspectiondays = str(ctx.inputs.get("inspectiondays", "26"))
    inspectionreadiness = str(ctx.inputs.get("inspectionreadiness", "75"))
    showtimestamp = ctx.inputs.get("showtimestamp", True)
    timestamputc = ctx.inputs.get("timestamputc", True)
    localclock = ctx.inputs.get("localclock", False)
    clocktimezone = str(ctx.inputs.get("clocktimezone", "America/Indiana/Indianapolis"))
    timestamp = str(ctx.inputs.get("timestamp", "MAN"))
    states = str(ctx.inputs.get("states", "Indiana"))
    statefilter = ",".join(states.split(",")[:5])
    feedurl = str(ctx.inputs.get("feedurl", ""))
    apikey = str(ctx.inputs.get("apikey", ""))

    if feedurl:
        headers = {}
        if apikey:
            headers = {"Authorization": "Bearer " + apikey}
        resp = http.get(feedurl, headers=headers, params={"states": statefilter}, ttl_seconds=300)
        if resp["status_code"] == 200:
            data = resp["json"]
            inspectiontype = str(data.get("inspection_type", inspectiontype))
            inspectionarea = str(data.get("inspection_area", inspectionarea))
            inspectiondate = str(data.get("inspection_date", inspectiondate))
            inspectiondays = str(data.get("inspection_days", inspectiondays))
            inspectionreadiness = str(data.get("inspection_readiness", inspectionreadiness))
            timestamp = str(data.get("display_timestamp", timestamp))
            timestamputc = data.get("timestamp_utc", timestamputc)
        else:
            timestamp = "ERROR"

    localclock = str(localclock).upper() != "FALSE" and str(localclock) != "0" and str(localclock).upper() != "NO"
    if localclock:
        clockresp = http.get(
            "https://timeapi.io/api/TimeZone/zone",
            params={"timeZone": clocktimezone},
            ttl_seconds=3600,
        )
        offsetseconds = None
        if clockresp["status_code"] == 200:
            clockdata = clockresp["json"]
            if clockdata:
                offsetseconds = clockdata.get("currentUtcOffset", {}).get("seconds", None)
        if offsetseconds != None:
            localseconds = (ctx.now.unix + int(offsetseconds)) % 86400
            localhour = localseconds // 3600
            localminute = (localseconds % 3600) // 60
            timestamp = ("0" + str(localhour))[-2:] + ":" + ("0" + str(localminute))[-2:]
        else:
            timestamp = "TZERR"
        timestamputc = False

    inspectiontype = inspectiontype.upper()
    inspectionarea = inspectionarea.upper()
    inspectiondate = inspectiondate.upper()
    inspectiondays = inspectiondays.upper()
    inspectionreadiness = inspectionreadiness.upper()
    timestamp = timestamp.upper()
    showtimestamp = str(showtimestamp).upper() != "FALSE" and str(showtimestamp) != "0" and str(showtimestamp).upper() != "NO"
    timestamputc = str(timestamputc).upper() != "FALSE" and str(timestamputc) != "0" and str(timestamputc).upper() != "NO"
    if not timestamputc and timestamp[-1:] == "Z":
        timestamp = timestamp[:-1]
    timestampcolor = "#718B7D"
    if timestamp == "ERROR" or timestamp == "TZERR":
        timestampcolor = "#FF3030"

    if not inspectiondays:
        inspectiondays = "?"
    due_label = "D-" + inspectiondays
    overdue = False
    if inspectiondays == "0":
        due_label = "DUE"
        overdue = True
    elif inspectiondays[:1] == "-":
        due_label = inspectiondays[1:5] + "D LATE"
        overdue = True

    readiness_value = int(inspectionreadiness)
    if readiness_value < 0:
        readiness_value = 0
    elif readiness_value > 100:
        readiness_value = 100
    readiness_width = readiness_value * 76 // 100

    accent = "#FFB000"
    if readiness_value == 100:
        accent = "#25E06F"
    if overdue:
        accent = "#FF3030"

    c.fill("#030504")
    c.rect(0, 0, 191, 31, outline="#294238")
    c.rect(0, 0, 3, 31, fill=accent)
    c.text("INSPECTION READY", 7, 1, font="4x5", color="#AFC5B8")
    if showtimestamp:
        c.text(timestamp[:5], 111, 1, font="4x5", color=timestampcolor)
    c.rect(141, 0, 190, 7, fill=accent)
    c.text(due_label[:9], 145, 1, font="4x5", color="#000000")
    c.hline(6, 190, 8, color="#294238")
    c.text((inspectiontype + " | " + inspectionarea)[:30], 7, 11, font="5x7", color="#FFFFFF")
    c.text(inspectiondate[:10], 7, 22, font="4x5", color="#AFC5B8")
    c.rect(65, 21, 145, 27, outline="#537060")
    c.rect(67, 23, 67 + readiness_width, 25, fill=accent)
    c.text((str(readiness_value) + "%")[:4], 151, 22, font="4x5", color=accent)


def actions(c, ctx):
    actiontext = str(ctx.inputs.get("actiontext", "REPAIR EXIT SIGN"))
    actionowner = str(ctx.inputs.get("actionowner", "FACILITIES"))
    actiondue = str(ctx.inputs.get("actiondue", "2026-08-25"))
    actiondays = str(ctx.inputs.get("actiondays", "5"))
    actionpriority = str(ctx.inputs.get("actionpriority", "HIGH"))
    showtimestamp = ctx.inputs.get("showtimestamp", True)
    timestamputc = ctx.inputs.get("timestamputc", True)
    localclock = ctx.inputs.get("localclock", False)
    clocktimezone = str(ctx.inputs.get("clocktimezone", "America/Indiana/Indianapolis"))
    timestamp = str(ctx.inputs.get("timestamp", "MAN"))
    states = str(ctx.inputs.get("states", "Indiana"))
    statefilter = ",".join(states.split(",")[:5])
    feedurl = str(ctx.inputs.get("feedurl", ""))
    apikey = str(ctx.inputs.get("apikey", ""))

    if feedurl:
        headers = {}
        if apikey:
            headers = {"Authorization": "Bearer " + apikey}
        resp = http.get(feedurl, headers=headers, params={"states": statefilter}, ttl_seconds=300)
        if resp["status_code"] == 200:
            data = resp["json"]
            actiontext = str(data.get("action_text", actiontext))
            actionowner = str(data.get("action_owner", actionowner))
            actiondue = str(data.get("action_due", actiondue))
            actiondays = str(data.get("action_days", actiondays))
            actionpriority = str(data.get("action_priority", actionpriority))
            timestamp = str(data.get("display_timestamp", timestamp))
            timestamputc = data.get("timestamp_utc", timestamputc)
        else:
            timestamp = "ERROR"

    localclock = str(localclock).upper() != "FALSE" and str(localclock) != "0" and str(localclock).upper() != "NO"
    if localclock:
        clockresp = http.get(
            "https://timeapi.io/api/TimeZone/zone",
            params={"timeZone": clocktimezone},
            ttl_seconds=3600,
        )
        offsetseconds = None
        if clockresp["status_code"] == 200:
            clockdata = clockresp["json"]
            if clockdata:
                offsetseconds = clockdata.get("currentUtcOffset", {}).get("seconds", None)
        if offsetseconds != None:
            localseconds = (ctx.now.unix + int(offsetseconds)) % 86400
            localhour = localseconds // 3600
            localminute = (localseconds % 3600) // 60
            timestamp = ("0" + str(localhour))[-2:] + ":" + ("0" + str(localminute))[-2:]
        else:
            timestamp = "TZERR"
        timestamputc = False

    actiontext = actiontext.upper()
    actionowner = actionowner.upper()
    actiondue = actiondue.upper()
    actiondays = actiondays.upper()
    actionpriority = actionpriority.upper()
    timestamp = timestamp.upper()
    showtimestamp = str(showtimestamp).upper() != "FALSE" and str(showtimestamp) != "0" and str(showtimestamp).upper() != "NO"
    timestamputc = str(timestamputc).upper() != "FALSE" and str(timestamputc) != "0" and str(timestamputc).upper() != "NO"
    if not timestamputc and timestamp[-1:] == "Z":
        timestamp = timestamp[:-1]
    timestampcolor = "#8F8170"
    if timestamp == "ERROR" or timestamp == "TZERR":
        timestampcolor = "#FF3030"

    if not actiondays:
        actiondays = "?"
    due_label = "D-" + actiondays
    overdue = False
    if actiondays == "0":
        due_label = "DUE"
        overdue = True
    elif actiondays[:1] == "-":
        due_label = actiondays[1:5] + "D LATE"
        overdue = True

    accent = "#00D9FF"
    if actionpriority == "HIGH":
        accent = "#FFB000"
    elif actionpriority == "CRITICAL":
        accent = "#FF3030"
    if overdue:
        accent = "#FF3030"

    c.fill("#050403")
    c.rect(0, 0, 191, 31, outline="#503B22")
    c.rect(0, 0, 3, 31, fill=accent)
    c.text("PRIORITY ACTION", 7, 1, font="4x5", color="#D0C2AF")
    if showtimestamp:
        c.text(timestamp[:5], 115, 1, font="4x5", color=timestampcolor)
    c.rect(144, 0, 190, 7, fill=accent)
    c.text(actionpriority[:8], 148, 1, font="4x5", color="#000000")
    c.hline(6, 190, 8, color="#503B22")
    c.text(actiontext[:30], 7, 11, font="5x7", color="#FFFFFF")
    c.text((actionowner[:9] + " | " + actiondue[:10] + " | " + due_label)[:36], 7, 22, font="4x5", color=accent)


def device(c, ctx):
    devicename = str(ctx.inputs.get("devicename", "LOBBY-01"))
    deviceonline = ctx.inputs.get("deviceonline", True)
    displaymode = str(ctx.inputs.get("displaymode", "ALL UPDATES"))
    brightness = str(ctx.inputs.get("brightness", "75"))
    showtimestamp = ctx.inputs.get("showtimestamp", True)
    timestamputc = ctx.inputs.get("timestamputc", True)
    localclock = ctx.inputs.get("localclock", False)
    clocktimezone = str(ctx.inputs.get("clocktimezone", "America/Indiana/Indianapolis"))
    timestamp = str(ctx.inputs.get("timestamp", "MAN"))
    timestampfull = str(ctx.inputs.get("timestampfull", "MANUAL"))
    timestamplabel = str(ctx.inputs.get("timestamplabel", "UPDATED"))
    states = str(ctx.inputs.get("states", "Indiana"))
    statefilter = ",".join(states.split(",")[:5])
    feedurl = str(ctx.inputs.get("feedurl", ""))
    apikey = str(ctx.inputs.get("apikey", ""))

    feed_state = "MANUAL"
    if feedurl:
        headers = {}
        if apikey:
            headers = {"Authorization": "Bearer " + apikey}
        resp = http.get(feedurl, headers=headers, params={"states": statefilter}, ttl_seconds=300)
        if resp["status_code"] == 200:
            data = resp["json"]
            devicename = str(data.get("device_name", devicename))
            deviceonline = data.get("device_online", deviceonline)
            displaymode = str(data.get("display_mode", displaymode))
            brightness = str(data.get("brightness", brightness))
            feed_state = str(data.get("feed_status", "LIVE"))
            timestamp = str(data.get("display_timestamp", timestamp))
            timestampfull = str(data.get("display_timestamp_full", timestampfull))
            timestamplabel = str(data.get("timestamp_label", timestamplabel))
            timestamputc = data.get("timestamp_utc", timestamputc)
        else:
            feed_state = "FEED ERR"
            timestamp = "ERROR"
            timestampfull = "FEED ERROR"
            timestamplabel = "STATUS"

    localclock = str(localclock).upper() != "FALSE" and str(localclock) != "0" and str(localclock).upper() != "NO"
    if localclock:
        clockresp = http.get(
            "https://timeapi.io/api/TimeZone/zone",
            params={"timeZone": clocktimezone},
            ttl_seconds=3600,
        )
        offsetseconds = None
        if clockresp["status_code"] == 200:
            clockdata = clockresp["json"]
            if clockdata:
                offsetseconds = clockdata.get("currentUtcOffset", {}).get("seconds", None)
        if offsetseconds != None:
            localseconds = (ctx.now.unix + int(offsetseconds)) % 86400
            localhour = localseconds // 3600
            localminute = (localseconds % 3600) // 60
            timestamp = ("0" + str(localhour))[-2:] + ":" + ("0" + str(localminute))[-2:]
            timestampfull = timestamp
        else:
            timestamp = "TZERR"
            timestampfull = "TZERR"
        timestamplabel = "LOCAL"
        timestamputc = False

    devicename = devicename.upper()
    displaymode = displaymode.upper()
    brightness = brightness.upper()
    feed_state = feed_state.upper()
    timestamp = timestamp.upper()
    timestampfull = timestampfull.upper()
    timestamplabel = timestamplabel.upper()
    showtimestamp = str(showtimestamp).upper() != "FALSE" and str(showtimestamp) != "0" and str(showtimestamp).upper() != "NO"
    timestamputc = str(timestamputc).upper() != "FALSE" and str(timestamputc) != "0" and str(timestamputc).upper() != "NO"
    if not timestamputc:
        if timestamp[-1:] == "Z":
            timestamp = timestamp[:-1]
        if timestampfull[-1:] == "Z":
            timestampfull = timestampfull[:-1]

    if feed_state != "MANUAL" and feed_state != "STALE" and feed_state != "FEED ERR":
        feed_state = "LIVE"

    online_text = str(deviceonline).upper()
    deviceonline = online_text != "FALSE" and online_text != "0" and online_text != "NO" and online_text != "OFFLINE"
    state = "ONLINE"
    accent = "#25E06F"
    if not deviceonline:
        state = "OFFLINE"
        accent = "#FF3030"

    brightness_value = int(brightness)
    if brightness_value < 0:
        brightness_value = 0
    elif brightness_value > 100:
        brightness_value = 100
    brightness_width = brightness_value * 78 // 100

    feed_color = "#25E06F"
    if feed_state == "MANUAL":
        feed_color = "#00D9FF"
    elif feed_state == "STALE":
        feed_color = "#FFB000"
    elif feed_state == "FEED ERR":
        feed_color = "#FF3030"

    c.fill("#020504")
    c.rect(0, 0, 191, 31, outline="#294238")
    c.rect(0, 0, 3, 31, fill=accent)
    if showtimestamp:
        timestampcolor = "#718B7D"
        if timestamp == "ERROR" or timestamp == "TZERR":
            timestampcolor = "#FF3030"
        c.text("DEVICE", 7, 1, font="4x5", color="#AFC5B8")
        c.text((timestamplabel[:3] + " " + timestampfull)[:19], 42, 1, font="4x5", color=timestampcolor)
    else:
        c.text("DEVICE CONTROL", 7, 1, font="4x5", color="#AFC5B8")
    c.fill_circle(148, 3, 2, color=accent)
    c.text(state, 154, 1, font="4x5", color=accent)
    c.hline(6, 190, 8, color="#294238")
    c.text((devicename + " | " + displaymode)[:30], 7, 11, font="5x7", color="#FFFFFF")
    c.text("BRT", 7, 22, font="4x5", color="#9DB3A7")
    c.rect(27, 21, 107, 27, outline="#537060")
    c.rect(29, 23, 29 + brightness_width, 25, fill=accent)
    c.text((str(brightness_value) + "%")[:4], 113, 22, font="4x5", color="#FFFFFF")
    c.text(feed_state, 150, 22, font="4x5", color=feed_color)
