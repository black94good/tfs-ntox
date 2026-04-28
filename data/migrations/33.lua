function onUpdateDatabase()
	logger.info("Updating database to version 33 (NTOX Shinobi vocation)")
	db.query("UPDATE `players` SET `vocation` = 1 WHERE `vocation` <> 0")
	return true
end
