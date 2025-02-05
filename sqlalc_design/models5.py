from sqlalchemy import (
    String,
    Integer,
    DateTime,
    CheckConstraint,
    PrimaryKeyConstraint,
    ForeignKeyConstraint,
    BigInteger,
    Index,
    Text,
    text
)
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column
from typing import Optional
import datetime


class Base(DeclarativeBase):
    pass


class TransactionMaster(Base):
    __tablename__ = 'transaction_master'
    transaction_code: Mapped[str] = mapped_column(String(50), primary_key=True)
    transaction_desc: Mapped[str] = mapped_column(String(200))
    transaction_type: Mapped[str] = mapped_column(String(50))
    __table_args__ = (
        CheckConstraint(
            "transaction_type::text = ANY (ARRAY['Internal'::text, 'Financial'::text, 'Non-Financial'::text]::text[])",
            name='txn_type_check')
    )


class TransactionBranchMapping(Base):
    __tablename__ = 'transaction_branch_mapping'
    id: Mapped[int] = mapped_column(BigInteger, primary_key=True)
    branch_id: Mapped[str] = mapped_column(String(50), nullable=False)
    transaction_code: Mapped[str] = mapped_column(String(50), nullable=False)
    __table_args__ = (
        ForeignKeyConstraint(['branch_id'], ['branch_master.branch_id'],
                             name='transaction_branch_mapping_fk_branch_id'),
        ForeignKeyConstraint(['transaction_code'], ['transaction_master.transaction_code'],
                             name='transaction_branch_mapping_fk_transaction_code'),
        Index('idx_transaction_branch_mapping_branch_id_reference', 'branch_id')
    )


class BranchMaster(Base):
    __tablename__ = 'branch_master'
    branch_id: Mapped[str] = mapped_column(String(50), primary_key=True)
    branch_name: Mapped[str] = mapped_column(String(255), nullable=False)
    branch_type: Mapped[str] = mapped_column(String(200))


class Session(Base):
    __tablename__ = 'session'
    branch_id: Mapped[str] = mapped_column(String(50), nullable=False)
    session_id: Mapped[str] = mapped_column(String(36), primary_key=True)
    customer_rep: Mapped[str] = mapped_column(String(1))
    authentication_method: Mapped[str] = mapped_column(String(20))
    cif: Mapped[str] = mapped_column(String(50), nullable=False)
    account_no: Mapped[dict] = mapped_column(JSONB, nullable=False, server_default=text("'{}'"))
    session_start: Mapped[datetime.datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    session_end: Mapped[datetime.datetime] = mapped_column(DateTime(timezone=True), nullable=True)
    userid: Mapped[str] = mapped_column(String(50), nullable=False)
    approver_provider: Mapped[str] = mapped_column(String(50), nullable=False)
    username: Mapped[str] = mapped_column(String(255), nullable=False)
    representative_data: Mapped[dict] = mapped_column(JSONB, nullable=True, server_default=text("'{}'"))  # {id_no, first_name, last_name, dob, gender}

    __table_args__ = (
        ForeignKeyConstraint(['branch_id'], ['branch_master.branch_id'], name='session_fk_branch_id'),
        CheckConstraint("customer_rep::text = ANY (ARRAY['C'::character varying, 'R'::character varying]::text[])",
                        name='customer_rep_check'),
        CheckConstraint(
            "authentication_method::text = ANY (ARRAY['Card'::text, 'CIF'::text, 'Phone Number'::text, 'Account number'::text, 'NID'::text, 'Passport'::text, 'DL'::text]::text[])",
            name='authentication_method_check'),
        Index('idx_session_account_no_gin', 'account_no', postgresql_using='gin'),
        Index('idx_session_reference', 'cif', 'session_end')
    )


class CurrencyMaster(Base):
    __tablename__ = 'currency_master'
    currency_code: Mapped[str] = mapped_column(String(3), primary_key=True)
    currency_name: Mapped[str] = mapped_column(String(100), nullable=False)


class CurrencyBranchMapping(Base):
    __tablename__ = 'currency_branch_mapping'
    id: Mapped[int] = mapped_column(BigInteger, primary_key=True)
    branch_id: Mapped[str] = mapped_column(String(50), nullable=False)
    currency_code: Mapped[str] = mapped_column(String(3), nullable=False)
    __table_args__ = (
        ForeignKeyConstraint(['branch_id'], ['branch_master.branch_id'],
                             name='currency_branch_mapping_fk_branch_id'),
        ForeignKeyConstraint(['currency_code'], ['currency_master.currency_code'],
                             name='currency_branch_mapping_fk_currency_code'),
        Index('idx_currency_branch_mapping_branch_id_reference', 'branch_id')
    )


class DenominationMaster(Base):
    __tablename__ = 'denomination_master'
    denomination_code: Mapped[str] = mapped_column(String(50), primary_key=True)
    denomination_label: Mapped[str] = mapped_column(String(100))
    denomination_value: Mapped[int] = mapped_column(Integer, nullable=False)

    __table_args__ = (
        CheckConstraint('denomination_value > 0', name='check_denomination_value_positive'),
    )


class DenominationBranchMapping(Base):
    __tablename__ = 'denomination_branch_mapping'
    id: Mapped[int] = mapped_column(BigInteger, primary_key=True)
    branch_id: Mapped[str] = mapped_column(String(50), nullable=False)
    currency_code: Mapped[str] = mapped_column(String(3), nullable=False)
    denomination_code: Mapped[str] = mapped_column(String(50), nullable=False)

    __table_args__ = (
        ForeignKeyConstraint(['currency_code'], ['currency_master.currency_code'],
                             name='denomination_branch_mapping_fk_ccy_code'),
        ForeignKeyConstraint(['branch_id'], ['branch_master.branch_id'],
                             name='denomination_branch_mapping_fk_branch_id'),
        ForeignKeyConstraint(['denomination_code'], ['denomination_master.denomination_code'],
                             name='denomination_branch_mapping_fk_denomination_code'),
        Index('idx_denomination_branch_mapping_denomination_reference', 'branch_id', 'currency_code')
    )


class Transactions(Base):
    __tablename__ = 'transactions'
    transaction_reference_no: Mapped[str] = mapped_column(String(50), primary_key=True)
    transaction_code: Mapped[str] = mapped_column(String(50), nullable=False)
    transaction_status: Mapped[Optional[str]] = mapped_column(String(1))
    auth_status: Mapped[Optional[str]] = mapped_column(String(1))
    session_id: Mapped[str] = mapped_column(String(36), nullable=False)
    created_at_branch_id: Mapped[str] = mapped_column(String(50), nullable=False)
    present_at_branch_id: Mapped[str] = mapped_column(String(50), nullable=False)
    created_by_username: Mapped[str] = mapped_column(String(255), nullable=False)
    created_by_user_id: Mapped[str] = mapped_column(String(50), nullable=False)
    approver_provider: Mapped[str] = mapped_column(String(50), nullable=False)
    create_timestamp: Mapped[datetime.datetime] = mapped_column(DateTime(timezone=True))
    last_updated_username: Mapped[str] = mapped_column(String(255), nullable=False)
    last_updated_user_id: Mapped[str] = mapped_column(String(50), nullable=False)
    last_updated_approver_provider: Mapped[str] = mapped_column(String(50), nullable=False)
    last_updated_timestamp: Mapped[datetime.datetime] = mapped_column(DateTime(timezone=True))
    screen_data: Mapped[dict] = mapped_column(JSONB, nullable=False, server_default=text("'{}'"))
    additional_data: Mapped[dict] = mapped_column(JSONB, server_default=text("'{}'"))
    callback_done: Mapped[str] = mapped_column(String(1))

    __table_args__ = (
        CheckConstraint(
            "transaction_status::text = ANY (ARRAY['D'::character varying, 'I'::character varying, 'B'::character varying, 'S'::character varying, 'F'::character varying, 'R'::character varying]::text[])",
            name='transaction_status_check'),
        CheckConstraint(
            "auth_status::text = ANY (ARRAY['A'::character varying, 'U'::character varying, 'R'::character varying]::text[])",
            name='auth_status_check'),
        CheckConstraint("callback_done::text = ANY (ARRAY['Y'::character varying, 'N'::character varying]::text[])",
                        name='callback_done_check'),
        ForeignKeyConstraint(['transaction_code'], ['transaction_master.transaction_code'],
                             name='txns_fk_transaction_code'),
        ForeignKeyConstraint(['session_id'], ['session.session_id'],
                             name='txns_fk_session_id'),
        ForeignKeyConstraint(['created_at_branch_id'], ['branch_master.branch_id'],
                             name='transactions_fk_created_branch_id'),
        ForeignKeyConstraint(['present_at_branch_id'], ['branch_master.branch_id'],
                             name='transactions_fk_present_branch_id'),
        Index('idx_transactions_status_reference', 'transaction_status'),
        Index('idx_transactions_created_by_reference', 'created_by_user_id'),
        Index('idx_transactions_created_at_reference', 'created_at_branch_id'),
        Index('idx_transactions_session_reference', 'session_id'),
        Index('idx_transactions_screen_data_gin', 'screen_data', postgresql_using='gin'),
        Index('idx_transactions_additional_data_gin', 'additional_data', postgresql_using='gin')
    )


class TransactionAuditLog(Base):
    __tablename__ = 'transaction_audit_log'
    id: Mapped[int] = mapped_column(BigInteger, primary_key=True)
    branch_id: Mapped[str] = mapped_column(String(50), nullable=False)
    transaction_reference_no: Mapped[str] = mapped_column(String(50), nullable=False)
    old_json: Mapped[dict] = mapped_column(JSONB, server_default=text("'{}'"))
    new_json: Mapped[dict] = mapped_column(JSONB, server_default=text("'{}'"))
    change_summary: Mapped[str] = mapped_column(Text, nullable=True)
    action: Mapped[str] = mapped_column(String(100))
    approver_provider: Mapped[str] = mapped_column(String(50), nullable=False)
    action_by_username: Mapped[str] = mapped_column(String(255), nullable=False)
    action_by_user_id: Mapped[str] = mapped_column(String(50), nullable=False)
    comments: Mapped[str] = mapped_column(Text, nullable=True)
    action_timestamp: Mapped[datetime.datetime] = mapped_column(DateTime(timezone=True), nullable=False)

    __table_args__ = (
        ForeignKeyConstraint(['transaction_reference_no'], ['transactions.transaction_reference_no'],
                             name='transaction_audit_log_fk_transaction_reference_no'),
        ForeignKeyConstraint(['branch_id'], ['branch_master.branch_id'],
                             name='transaction_audit_log_fk_branch_id'),
        Index('idx_transaction_audit_reference', 'transaction_reference_no'),
        Index('idx_transaction_audit_old_json_gin', 'old_json', postgresql_using='gin'),
        Index('idx_transaction_audit_new_json_gin', 'new_json', postgresql_using='gin')

    )
    

class TillTypeMapping(Base):
    __tablename__ = 'till_type_mapping'
    till_id: Mapped[int] = mapped_column(String(50), primary_key=True)
    till_type: Mapped[str] = mapped_column(String(20), nullable=False)



class TillMaster(Base):
    __tablename__ = 'till_master'
    branch_id: Mapped[str] = mapped_column(String(50), nullable=False)
    till_id: Mapped[int] = mapped_column(String(50), nullable=False)
    currency_code: Mapped[str] = mapped_column(String(3), nullable=False)
    current_denominations: Mapped[dict] = mapped_column(JSONB, server_default=text("'{}'"))
    current_balance: Mapped[int] = mapped_column(Integer)
    opening_denominations: Mapped[dict] = mapped_column(JSONB, server_default=text("'{}'"))
    opening_balance: Mapped[int] = mapped_column(Integer)
    __table_args__ = (
        PrimaryKeyConstraint('branch_id', 'till_id', 'currency_code', name='till_master_pkey'),
        ForeignKeyConstraint(['currency_code'], ['currency_master.currency_code'],
                             name='till_master_fk_currency_code'),
        ForeignKeyConstraint(['branch_id'], ['branch_master.branch_id'],
                             name='till_master_fk_branch_id'),
        ForeignKeyConstraint(['till_id'], ['till_type_mapping.till_id'],
                             name='till_type_mapping_fk_till_id'),

    )


class UserTillMaster(Base):
    __tablename__ = 'user_till_master'
    branch_id: Mapped[str] = mapped_column(String(50), nullable=False)
    userid: Mapped[str] = mapped_column(String(50), nullable=False, unique=True)
    username: Mapped[str] = mapped_column(String(255), nullable=False)
    till_id: Mapped[int] = mapped_column(String(50), unique=True)
    approver_provider: Mapped[str] = mapped_column(String(50), nullable=False)
    approver_id: Mapped[str] = mapped_column(String(50), nullable=False)
    approver_name: Mapped[str] = mapped_column(String(255), nullable=False)

    __table_args__ = (
        PrimaryKeyConstraint('branch_id', 'userid', name='user_till_master_pkey'),
        ForeignKeyConstraint(['till_id'], ['till_type_mapping.till_id'],
                             name='user_till_master_fk_till_id'),
        ForeignKeyConstraint(['branch_id'], ['branch_master.branch_id'],
                             name='user_till_master_fk_branch_id')
    )


class TransactionDenomination(Base):
    __tablename__ = 'transaction_denomination'
    branch_id: Mapped[str] = mapped_column(String(50), nullable=False)
    transaction_reference_no: Mapped[str] = mapped_column(String(50), nullable=False)
    till_id: Mapped[int] = mapped_column(String(50), nullable=False)
    currency_code: Mapped[str] = mapped_column(String(3), nullable=False)
    related_account: Mapped[str] = mapped_column(String(50))
    amount: Mapped[int] = mapped_column(Integer, nullable=False)
    denominations: Mapped[dict] = mapped_column(JSONB, server_default=text("'{}'"))
    transaction_date: Mapped[datetime.datetime] = mapped_column(DateTime(timezone=True), nullable=False)

    __table_args__ = (
        PrimaryKeyConstraint('transaction_reference_no', 'till_id', 'currency_code',
                             name='transaction_denomination_pkey'),
        ForeignKeyConstraint(['transaction_reference_no'], ['transactions.transaction_reference_no'],
                             name='transaction_denomination_fk_transaction_reference_no'),
        ForeignKeyConstraint(['till_id'], ['till_type_mapping.till_id'],
                             name='transaction_denomination_fk_till_id'),
        ForeignKeyConstraint(['currency_code'], ['currency_master.currency_code'],
                             name='transaction_denomination_fk_currency_code'),
        ForeignKeyConstraint(['branch_id'], ['branch_master.branch_id'],
                             name='transaction_denomination_fk_branch_id'),
        Index('idx_transaction_denomination_reference', 'transaction_date')
    )