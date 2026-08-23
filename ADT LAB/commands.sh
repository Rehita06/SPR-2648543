# ============================================================
# LAB - 8 : Import, Export, Dump, and Restore Operations in MongoDB
# Run these from Command Prompt / terminal (not mongosh)
# Adjust file paths to your own machine as needed.
# ============================================================

# ------------------------------------------------------------
# Import the prepared dataset
# ------------------------------------------------------------
mongoimport --db canteendb --collection users --file "E:\MongoLab\users.json"
# 5 document(s) imported successfully. 0 document(s) failed to import.

# Append additional records
mongoimport --db canteendb --collection users --file "E:\MongoLab\users_extra.json"
# 5 document(s) imported successfully. 0 document(s) failed to import.

# ------------------------------------------------------------
# Export the collection
# ------------------------------------------------------------
mongoexport --db canteendb --collection users --out "E:\MongoLab\export\users_export.json"
# exported 10 records

# ------------------------------------------------------------
# Create a complete backup (dump) of the database
# ------------------------------------------------------------
mongodump --db canteendb --out "E:\MongoLab\backup"
# writing canteendb.users to E:\MongoLab\backup\canteendb\users.bson
# writing canteendb.menu_items ...
# writing canteendb.vendors ...
# writing canteendb.orders ...
# writing canteendb.order_items ...
# done dumping all collections

# ------------------------------------------------------------
# Restore the backup
# ------------------------------------------------------------
mongorestore --drop --db canteendb "E:\MongoLab\backup\canteendb"
# building a list of collections to restore from the backup dir
# dropping and restoring each collection
# 33 document(s) restored successfully. 0 document(s) failed to restore.
