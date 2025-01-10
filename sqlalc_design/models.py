from sqlalchemy import (
    Column,
    String,
    Integer,
    ForeignKey,
    JSON,
    TIMESTAMP,
    CHAR,
    CheckConstraint,
    PrimaryKeyConstraint,
    Float
)
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import declarative_base
from sqlalchemy.dialects.postgresql import JSONB
import uuid

Base = declarative_base()

class TransactionMaster(Base):
    __tablename__ = "transaction_master"
    tenant = Column(String(50), nullable=False)
    branch_id = Column(Integer, nullable=False)
    transaction_code = Column(String(50), primary_key=True)
    transaction_desc = Column(String(200), nullable=False)


class BranchMaster(Base):
    __tablename__ = "branch_master"
    tenant = Column(String(50), nullable=False)
    branch_id = Column(Integer, primary_key=True)
    branch_name = Column(String(50), nullable=False)
    branch_type = Column(String(200))


class SessionMaster(Base):
    __tablename__ = "session_master"
    # tenant = Column(String(50), nullable=False)
    # branch_id = Column(Integer, nullable=False)
    # sessionid = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    # customer_rep = Column(CHAR(1))
    # authentication_method = Column(String(20))
    # cif = Column(String(50), nullable=False)
    # account_no = Column(JSON)
    # session_start = Column(TIMESTAMP(timezone=True))
    # session_end = Column(TIMESTAMP(timezone=True))
    # userid = Column(Integer)
    # provider_name = Column(String(50))
    # username = Column(String(100))
    # id_type = Column(String(20))
    # id_no = Column(String(50))
    # first_name = Column(String(50))
    # last_name = Column(String(50))
    # dob = Column(TIMESTAMP(timezone=False))
    # gender = Column(CHAR(1))
    # __table_args__ = (
    #     CheckConstraint("customer_rep IN ('C', 'R')", name="check_customer_rep"),
    #     CheckConstraint("gender IN ('M', 'F', 'O')", name="check_gender_valid_values"),
    #     CheckConstraint("authentication_method IN ('Card', 'CIF', 'Account number', 'NID', 'Passport', 'DL')", name="check_auth_method")
    # )


class CurrencyMaster(Base):
    __tablename__ = "currency_master"
    tenant = Column(String(50), nullable=False)
    branch_id = Column(Integer, nullable=False)
    currency_code = Column(String(5), primary_key=True)
    currency_name = Column(String(50))


class DenominationMaster(Base):
    __tablename__ = "denomination_master"
    tenant = Column(String(50), nullable=False)
    branch_id = Column(Integer, nullable=False)
    currency_code = Column(String(5), ForeignKey("currency_master.currency_code"), nullable=False)
    denomination_code = Column(Integer, primary_key=True)
    denomination_label = Column(String(50))
    denomination_value = Column(Float, nullable=False)
    __table_args__ = ( PrimaryKeyConstraint("currency_code", "denomination_value"),)

class Transactions(Base):
    __tablename__ = "transactions"
    tenant = Column(String(50), nullable=False)
    branch_id = Column(Integer, nullable=False)
    transaction_id = Column(String(20), nullable=False, unique=True)
    sessionid = Column(UUID(as_uuid=True), ForeignKey("session_master.sessionid"))
    transaction_code = Column(String(50), ForeignKey("transaction_master.transaction_code"), nullable=False)
    transaction_status = Column(CHAR(1))
    auth_status = Column(CHAR(1))
    created_by = Column(String(50))
    created_by_user_id = Column(Integer)
    created_by_provider = Column(String(50))
    create_timestamp = Column(TIMESTAMP(timezone=True))
    last_updated_user = Column(String(50))
    last_updated_user_id = Column(Integer)
    last_updated_user_provider = Column(String(50))
    last_updated_timestamp = Column(TIMESTAMP(timezone=True))
    comments = Column(CHAR(1))
    callback_done = Column(CHAR(1))
    data_table = Column(JSONB, nullable=False)
    __table_args__ = (
        CheckConstraint("transaction_status IN ('D', 'I', 'B', 'S', 'F', 'R')", name="check_txn_status"),
        CheckConstraint("auth_status IN ('A', 'U', 'R')", name="check_auth_status"),
        CheckConstraint("comments IN ('Y', 'N')", name="check_comments"),
        CheckConstraint("callback_done IN ('Y', 'N')", name="check_callback"),
        PrimaryKeyConstraint("transaction_id", "transaction_status"),
    )

class FinancialTransactions(Base):
    __tablename__ = "financial_transactions"
    tenant = Column(String(50), nullable=False)
    branch_id = Column(Integer, nullable=False)
    sessionid = Column(UUID(as_uuid=True), ForeignKey("session_master.sessionid"))
    transaction_id = Column(Integer, ForeignKey("transactions.transaction_id"), primary_key=True)
    denom_tracking = Column(CHAR(1))
    from_account = Column(String(50))
    to_account = Column(String(50))
    from_currency = Column(String(50))
    to_currency = Column(String(50))
    from_amount = Column(Integer)
    to_amount = Column(Integer)
    source_of_funds = Column(String(100))
    purpose = Column(String(100))
    remarks1 = Column(String(50))
    remarks2 = Column(String(50))
    exchange_rate_type = Column(String(50))
    exchange_rate = Column(String(50))
    special_rate = Column(CHAR(1))
    treasury_remarks = Column(String(50))
    treasury_approved = Column(String(50))
    treasury_approved_date = Column(TIMESTAMP(timezone=True))
    instrument_type = Column(String(50))
    instrument_date = Column(TIMESTAMP(timezone=True))
    instrument_number = Column(String(50))
    value_date = Column(TIMESTAMP(timezone=True))
    __table_args__ = (
        CheckConstraint("denom_tracking IN ('Y', 'N')", name="check_deno_tracking"),
        CheckConstraint("special_rate IN ('Y', 'N')", name="check_special_rate"),
        CheckConstraint("treasury_approved IN ('Y', 'N')", name="check_treasury_approved"),
    )

class Comments(Base):
    __tablename__ = "comments"
    tenant = Column(String(50), nullable=False)
    branch_id = Column(Integer, nullable=False)
    sessionid = Column(UUID(as_uuid=True), ForeignKey("session_master.sessionid"))
    transaction_id = Column(Integer, ForeignKey("transactions.transaction_id"), primary_key=True)
    sequence_number = Column(Integer, primary_key=True)
    user_provider = Column(String(50))
    username = Column(String(50), nullable=False)
    userid = Column(Integer, nullable=False)
    comments = Column(String(100), nullable=False)
    comments_date = Column(TIMESTAMP(timezone=True), nullable=False)


class TillMaster(Base):
    __tablename__ = "till_master"
    tenant = Column(String(50), nullable=False)
    branch_id = Column(Integer, nullable=False)
    till_id = Column(Integer)
    till_status = Column(CHAR(1))
    till_type = Column(String(20))
    currency_code = Column(String(5), ForeignKey("currency_master.currency_code"))
    denominations = Column(JSONB, nullable=False)
    amount = Column(Integer)
    __table_args__ = (
        CheckConstraint("till_status IN ('O', 'C')", name="check_till_status"),
        CheckConstraint("till_type IN ('Till', 'vault', 'chief teller', 'cash centre')", name="check_till_type"),
        PrimaryKeyConstraint("tenant", "branch_id", "till_id", "currency_code"),
    )


class UserTillMaster(Base):
    __tablename__ = 'user_till_master'
    tenant = Column(String(50), nullable=False, primary_key=True)
    branch_id = Column(Integer, ForeignKey('branch_master.branch_id'), nullable=False, primary_key=True)
    user_provider = Column(String(50))
    username = Column(String(100), nullable=False)
    userid = Column(Integer, nullable=False, primary_key=True)
    till_id = Column(Integer, unique=True)
    aprover_provider = Column(String(20))
    aprover_id = Column(Integer, nullable=False)
    aprover_name = Column(String(20))
    __table_args__ = (
        PrimaryKeyConstraint("tenant", "branch_id", "userid"),
    )

class AuditLogTxn(Base):
    __tablename__ = 'audit_log_txns'
    tenant = Column(String(50), nullable=False)
    branch_id = Column(Integer, nullable=False)
    audit_id = Column(Integer, primary_key=True)
    transaction_id = Column(String(50), ForeignKey('transactions.transaction_id'), nullable=False)
    till_id = Column(Integer, nullable=False)
    currency_code = Column(String(50), nullable=False)
    amount = Column(Integer, nullable=False)
    updated_denominations = Column(JSONB, nullable=False)
    update_date = Column(TIMESTAMP(timezone=False))
    userid = Column(Integer, nullable=False)
    username = Column(String(50), nullable=False)

class TransactionDenomination(Base):
    __tablename__ = 'transaction_denomination'
    tenant = Column(String(50), nullable=False)
    branch_id = Column(Integer, nullable=False)
    transaction_id = Column(String(50), ForeignKey("transactions.transaction_id"), unique=True )
    till_id = Column(Integer, nullable=False)
    currency_code = Column(String(50), nullable=False)
    related_account = Column(String(50))
    amount = Column(Integer, nullable=False)
    denominations = Column(JSONB, nullable=False)
    __table_args__ = (
        PrimaryKeyConstraint("tenant", "branch_id", "transaction_id"),
    )

