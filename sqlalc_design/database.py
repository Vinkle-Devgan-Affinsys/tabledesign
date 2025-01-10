from sqlalchemy import create_engine
from sqlalchemy.orm import Session
from models import Base

DATABASE_URL = "postgresql://username:password@localhost/dbname"

engine = create_engine(DATABASE_URL)
# session = Session(bind=engine)

#creating tables
def create_tables():
    Base.metadata.create_all(bind=engine)

#creating session
def create_session():
    return Session(bind=engine)


# from database import init_db, SessionLocal
# from models import TransactionMaster

# def main():
#     # Initialize the database
#     init_db()

#     # Create a session
#     db = SessionLocal()

#     # Example usage
#     new_transaction = TransactionMaster(
#         tenant="Tenant1",
#         branch_id=1,
#         transaction_code="TXN123",
#         transaction_desc="Sample transaction",
#     )
#     db.add(new_transaction)
#     db.commit()
#     db.close()

# if __name__ == "__main__":
#     main()
