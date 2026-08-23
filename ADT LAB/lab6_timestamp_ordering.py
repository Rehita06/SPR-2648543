"""
LAB - 6 : Timestamp Ordering Protocol - Campus Canteen Management System

Timestamp Ordering Protocol is a concurrency control method in which
every transaction is assigned a unique timestamp, and all read and
write operations are allowed or rejected based on these timestamps
to ensure serializability. Its main goal is to prevent conflicts and
maintain the correct order of transactions.
"""

# ---------------------------------------------------------------
# Step 1: Schema Design (FOOD_ITEM data item)
# ---------------------------------------------------------------
item_name = "BURGER"
stock = 50
read_ts = 0
write_ts = 0
# The value 0 means no transaction has accessed the item yet.
# Read_TS / Write_TS are used by the Timestamp Ordering protocol
# to maintain the correct order of concurrent transactions and
# prevent conflicts.

# ---------------------------------------------------------------
# Step 2: Transactions with logical timestamps
# ---------------------------------------------------------------
T1 = 5   # Student checks stock
T2 = 10  # Vendor updates stock (10 > 5, so T2 is the younger transaction)

print("Initial Food Item:", item_name)
print("Initial Stock:", stock)

# ---------------------------------------------------------------
# Step 3: Read Operation
# ---------------------------------------------------------------
# T1 = 5, Write_TS = 0 -> condition: 5 >= 0 -> True -> T1 allowed to read
if T1 >= write_ts:
    read_ts = T1
    print("T1 READ Success - Stock =", stock)

# ---------------------------------------------------------------
# Step 4: Write Operation
# ---------------------------------------------------------------
# T2 = 10, Read_TS = 5, Write_TS = 0
# Rule 1: 10 >= 5  -> True
# Rule 2: 10 >= 0  -> True
# Since both are true, the write is allowed.
if T2 >= read_ts and T2 >= write_ts:
    stock = 40
    write_ts = T2
    print("T2 WRITE Success - Updated Stock =", stock)

# ---------------------------------------------------------------
# Step 5: Older transaction tries to write
# ---------------------------------------------------------------
# T1 = 5, Read_TS = 5, Write_TS = 10
# Condition 1: 5 < 5   -> False
# Condition 2: 5 < 10  -> True
# Since one condition is true, T1 is rejected (aborted).
if T1 < read_ts or T1 < write_ts:
    print("T1 WRITE Rejected (Transaction Aborted)")
    print("Final Stock:", stock)
    print("Read_TS =", read_ts)
    print("Write_TS =", write_ts)

# ---------------------------------------------------------------
# Why is T1's write rejected?
# ---------------------------------------------------------------
# T1 is an older transaction. A newer transaction (T2) has already
# updated the stock. If T1 were allowed to write now, it would
# overwrite the latest value and create an incorrect order of
# transactions (e.g. T2 updates stock to 40, then T1 tries to
# overwrite it with a stale value). The Timestamp Ordering
# Protocol prevents this by rejecting/aborting T1.

# Expected output:
# Initial Food Item: BURGER
# Initial Stock: 50
# T1 READ Success - Stock = 50
# T2 WRITE Success - Updated Stock = 40
# T1 WRITE Rejected (Transaction Aborted)
# Final Stock: 40
# Read_TS = 5
# Write_TS = 10
