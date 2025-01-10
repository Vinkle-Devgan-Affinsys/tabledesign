from database import create_session, create_tables
from models import TransactionMaster

# Create tables in the database
create_tables()

# Create a new session
session = create_session()

# Example: Add a new user
new_txn = TransactionMaster('fcbsmartbranch', 1, 'TX001', 'Cash Deposit Same Currency')
session.add(new_txn)
session.commit()

# Example: Query users
txns = session.query(TransactionMaster).all()
for txn in txns:
    print(txn.branch_id, txn.transaction_desc)

# Close the session
session.close()
