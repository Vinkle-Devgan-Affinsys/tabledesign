from typing import List, Optional
from sqlalchemy import (BigInteger,
                        CHAR,
                        CheckConstraint,
                        DateTime,
                        ForeignKeyConstraint,
                        Index,
                        Integer,
                        PrimaryKeyConstraint,
                        Sequence,
                        String,
                        Text,
                        UniqueConstraint,
                        text)
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship
import datetime
import uuid


class Base(DeclarativeBase):
    pass


class Application(Base):
    __tablename__ = 'application'
    __table_args__ = (
        CheckConstraint("display_in_queue::text = ANY (ARRAY['Y'::character varying, 'N'::character varying]::text[])",
                        name='application_display_in_queue_check'),
        CheckConstraint(
            "file_upload_status::text = ANY (ARRAY['Y'::character varying, 'N'::character varying]::text[])",
            name='application_file_upload_status_check'),
        PrimaryKeyConstraint('id', name='application_pkey'),
        UniqueConstraint('tenant', 'internal_reference', 'version_no', name='application_reference_version_unique'),
        Index('idx_application_additional_keys_gin', 'additional_keys', postgresql_using='gin'),
        Index('idx_application_data_gin', 'data', postgresql_using='gin')
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True)
    tenant: Mapped[str] = mapped_column(String(255))
    internal_reference: Mapped[str] = mapped_column(String(255))
    version_no: Mapped[int] = mapped_column(Integer) 
    application_type: Mapped[str] = mapped_column(String(255))
    customer_type: Mapped[str] = mapped_column(String(255))
    external_reference: Mapped[Optional[str]] = mapped_column(String(255))
    kyc_reference: Mapped[Optional[str]] = mapped_column(String(255))
    onboarding_channel: Mapped[Optional[str]] = mapped_column(String(255))
    product_key: Mapped[Optional[str]] = mapped_column(String(255))
    product_name: Mapped[Optional[str]] = mapped_column(String(255))
    data: Mapped[Optional[dict]] = mapped_column(JSONB)
    additional_keys: Mapped[Optional[dict]] = mapped_column(JSONB)
    common_data: Mapped[Optional[dict]] = mapped_column(JSONB)
    additional_data: Mapped[Optional[dict]] = mapped_column(JSONB)
    file_upload_status: Mapped[Optional[str]] = mapped_column(String(1))
    user_role: Mapped[Optional[str]] = mapped_column(String(255))
    user_group: Mapped[Optional[str]] = mapped_column(String(255))
    primary_contact_number: Mapped[Optional[str]] = mapped_column(String(50))
    primary_email_address: Mapped[Optional[str]] = mapped_column(String(255))
    queue_code: Mapped[Optional[str]] = mapped_column(String(255))
    queue_name: Mapped[Optional[str]] = mapped_column(String(255))
    create_by: Mapped[Optional[str]] = mapped_column(String(255))
    create_by_uid: Mapped[Optional[str]] = mapped_column(String(255))
    create_by_provider: Mapped[Optional[str]] = mapped_column(String(255))
    create_timestamp: Mapped[Optional[datetime.datetime]] = mapped_column(DateTime(timezone=True))
    last_action: Mapped[Optional[str]] = mapped_column(String(255))
    last_action_performed_by: Mapped[Optional[str]] = mapped_column(String(255))
    last_action_by_provider: Mapped[Optional[str]] = mapped_column(String(255))
    last_action_performed_by_uuid: Mapped[Optional[str]] = mapped_column(String(255))
    last_action_perform_timestamp: Mapped[Optional[datetime.datetime]] = mapped_column(DateTime(timezone=True))
    last_modified_by: Mapped[Optional[str]] = mapped_column(String(255))
    last_modified_by_provider: Mapped[Optional[str]] = mapped_column(String(255))
    last_modified_by_uuid: Mapped[Optional[str]] = mapped_column(String(255))
    last_modified_timestamp: Mapped[Optional[datetime.datetime]] = mapped_column(DateTime(timezone=True))
    submit_by: Mapped[Optional[str]] = mapped_column(String(255))
    submit_by_provider: Mapped[Optional[str]] = mapped_column(String(255))
    submit_by_uuid: Mapped[Optional[str]] = mapped_column(String(255))
    submit_timestamp: Mapped[Optional[datetime.datetime]] = mapped_column(DateTime(timezone=True))
    display_in_queue: Mapped[Optional[str]] = mapped_column(String(1))
    rejected_by: Mapped[Optional[str]] = mapped_column(String(255))
    rejected_by_provider: Mapped[Optional[str]] = mapped_column(String(255))
    rejected_by_uuid: Mapped[Optional[str]] = mapped_column(String(255))
    rejected_timestamp: Mapped[Optional[datetime.datetime]] = mapped_column(DateTime(timezone=True))
    discarded_by: Mapped[Optional[str]] = mapped_column(String(255))
    discarded_by_provider: Mapped[Optional[str]] = mapped_column(String(255))
    discarded_by_uuid: Mapped[Optional[str]] = mapped_column(String(255))
    discarded_timestamp: Mapped[Optional[datetime.datetime]] = mapped_column(DateTime(timezone=True))

    application_files: Mapped[List['ApplicationFiles']] = relationship('ApplicationFiles', back_populates='application')
    subapplication: Mapped[List['Subapplication']] = relationship('Subapplication', back_populates='application')


class ApplicationAuditComments(Base):
    __tablename__ = 'application_audit_comments'
    __table_args__ = (
        PrimaryKeyConstraint('id', name='application_audit_comments_pkey'),
        Index('idx_application_audit_comments_reference', 'tenant', 'internal_reference', 'version_no')
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True)
    tenant: Mapped[str] = mapped_column(String(255))
    internal_reference: Mapped[str] = mapped_column(String(255))
    version_no: Mapped[int] = mapped_column(Integer)
    comments: Mapped[Optional[str]] = mapped_column(Text)
    created_by: Mapped[Optional[str]] = mapped_column(String(255))
    created_by_uuid: Mapped[Optional[str]] = mapped_column(String(255))
    created_by_provider: Mapped[Optional[str]] = mapped_column(String(255))
    create_timestamp: Mapped[datetime.datetime] = mapped_column(DateTime(timezone=True))
    queue_code: Mapped[Optional[str]] = mapped_column(String(255))
    action_code: Mapped[Optional[str]] = mapped_column(String(100))


class ApplicationAuditHistory(Base):
    __tablename__ = 'application_audit_history'
    __table_args__ = (
        PrimaryKeyConstraint('id', name='application_audit_history_pkey'),
        Index('idx_application_audit_history_reference', 'tenant', 'internal_reference', 'version_no')
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True)
    tenant: Mapped[str] = mapped_column(String(255))
    internal_reference: Mapped[str] = mapped_column(String(255))
    version_no: Mapped[int] = mapped_column(Integer)
    action: Mapped[str] = mapped_column(String(255))
    performed_by: Mapped[Optional[str]] = mapped_column(String(255))
    performed_by_uid: Mapped[Optional[str]] = mapped_column(String(255))
    performed_by_provider: Mapped[Optional[str]] = mapped_column(String(255))
    perform_timestamp: Mapped[Optional[datetime.datetime]] = mapped_column(DateTime(timezone=True))
    change_summary: Mapped[Optional[str]] = mapped_column(Text)
    old_data: Mapped[Optional[dict]] = mapped_column(JSONB)
    new_data: Mapped[Optional[dict]] = mapped_column(JSONB)


class ApplicationRoutingHistory(Base):
    __tablename__ = 'application_routing_history'
    __table_args__ = (
        PrimaryKeyConstraint('id', name='application_routing_history_pkey'),
        Index('idx_application_routing_history_reference', 'tenant', 'internal_reference', 'version_no')
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True)
    tenant: Mapped[str] = mapped_column(String(255))
    internal_reference: Mapped[str] = mapped_column(String(255))
    version_no: Mapped[int] = mapped_column(Integer)
    route_dump: Mapped[Optional[dict]] = mapped_column(JSONB)
    condition_dump: Mapped[Optional[dict]] = mapped_column(JSONB)
    performed_by: Mapped[Optional[str]] = mapped_column(String(255))
    performed_by_uuid: Mapped[Optional[str]] = mapped_column(String(255))
    performed_by_provider: Mapped[Optional[str]] = mapped_column(String(255))
    perform_timestamp: Mapped[datetime.datetime] = mapped_column(DateTime(timezone=True))


class ProductMapping(Base):
    __tablename__ = 'product_mapping'
    __table_args__ = (
        PrimaryKeyConstraint('id', name='product_mapping_pkey'),
        UniqueConstraint('tenant', 'product_key', name='unique_tenant_product_key'),
        Index('idx_product_mapping_product_key', 'product_key'),
        Index('idx_product_mapping_product_metadata', 'product_metadata'),
        Index('idx_product_mapping_tenant', 'tenant')
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True)
    tenant: Mapped[str] = mapped_column(String(255))
    product_key: Mapped[str] = mapped_column(String(255))
    product_name: Mapped[str] = mapped_column(String(255))
    product_icon_path: Mapped[Optional[str]] = mapped_column(Text)
    product_channel: Mapped[Optional[str]] = mapped_column(String(254))
    scheme_description: Mapped[Optional[dict]] = mapped_column(JSONB)
    documents_required: Mapped[Optional[dict]] = mapped_column(JSONB)
    key_fact_path: Mapped[Optional[str]] = mapped_column(Text)
    product_metadata: Mapped[Optional[dict]] = mapped_column(JSONB)


class RoutingRules(Base):
    __tablename__ = 'routing_rules'
    __table_args__ = (
        PrimaryKeyConstraint('id', name='routing_rules_pkey'),
        UniqueConstraint('route_condition_id', name='routing_rules_route_condition_id_key'),
        Index('idx_routing_rules_route_condition_id', 'route_condition_id'),
        Index('idx_routing_rules_route_condition_name', 'route_condition_name')
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True)
    tenant: Mapped[str] = mapped_column(String(255))
    route_condition: Mapped[dict] = mapped_column(JSONB)
    route_condition_name: Mapped[Optional[str]] = mapped_column(String(255))
    route_condition_id: Mapped[uuid.UUID] = mapped_column(UUID, server_default=text('gen_random_uuid()'))

    routing_log: Mapped[List['RoutingLog']] = relationship('RoutingLog', back_populates='route_condition')


class SubapplicationAuditComments(Base):
    __tablename__ = 'subapplication_audit_comments'
    __table_args__ = (
        PrimaryKeyConstraint('id', name='subapplication_audit_comments_pkey'),
        Index('idx_subapplication_audit_comments_reference', 'tenant', 'internal_reference', 'version_no')
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True)
    tenant: Mapped[str] = mapped_column(String(255))
    internal_reference: Mapped[str] = mapped_column(String(50))
    version_no: Mapped[int] = mapped_column(Integer)
    comments: Mapped[Optional[str]] = mapped_column(Text)
    created_by_uuid: Mapped[Optional[str]] = mapped_column(String(255))
    created_by: Mapped[Optional[str]] = mapped_column(String(255))
    created_by_provider: Mapped[Optional[str]] = mapped_column(String(255))
    create_timestamp: Mapped[datetime.datetime] = mapped_column(DateTime(timezone=True))
    queue_code: Mapped[Optional[str]] = mapped_column(String(255))
    action_code: Mapped[Optional[str]] = mapped_column(String(255))


class SubapplicationAuditHistory(Base):
    __tablename__ = 'subapplication_audit_history'
    __table_args__ = (
        PrimaryKeyConstraint('id', name='subapplication_audit_history_pkey'),
        Index('idx_subapplication_audit_history_reference', 'tenant', 'internal_reference', 'version_no')
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True)
    tenant: Mapped[str] = mapped_column(String(255))
    internal_reference: Mapped[str] = mapped_column(String(255))
    version_no: Mapped[int] = mapped_column(Integer)
    action: Mapped[str] = mapped_column(String(255))
    performed_by: Mapped[str] = mapped_column(String(255))
    performed_by_uid: Mapped[str] = mapped_column(String(255))
    performed_by_provider: Mapped[Optional[str]] = mapped_column(String(255))
    change_summary: Mapped[Optional[str]] = mapped_column(Text)
    old_data: Mapped[Optional[dict]] = mapped_column(JSONB)
    new_data: Mapped[Optional[dict]] = mapped_column(JSONB)


class SubapplicationRoutingHistory(Base):
    __tablename__ = 'subapplication_routing_history'
    __table_args__ = (
        PrimaryKeyConstraint('id', name='subapplication_routing_history_pkey'),
        Index('idx_subapplication_routing_history_reference', 'tenant', 'internal_reference', 'version_no')
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True)
    tenant: Mapped[str] = mapped_column(String(255))
    internal_reference: Mapped[str] = mapped_column(String(255))
    version_no: Mapped[int] = mapped_column(Integer)
    route_dump: Mapped[Optional[dict]] = mapped_column(JSONB)
    condition_dump: Mapped[Optional[dict]] = mapped_column(JSONB)
    performed_by: Mapped[Optional[str]] = mapped_column(String(255))
    performed_by_provider: Mapped[Optional[str]] = mapped_column(String(255))
    performed_by_uuid: Mapped[Optional[str]] = mapped_column(String(255))
    perform_timestamp: Mapped[datetime.datetime] = mapped_column(DateTime(timezone=True))


class ApplicationFiles(Base):
    __tablename__ = 'application_files'
    __table_args__ = (
        ForeignKeyConstraint(['tenant', 'internal_reference', 'version_no'],
                             ['application.tenant', 'application.internal_reference', 'application.version_no'],
                             name='application_files_tenant_internal_reference_version_no_fkey'),
        PrimaryKeyConstraint('id', name='application_files_pkey'),
        Index('idx_application_files_key_name', 'key_name'),
        Index('idx_application_files_obj_path', 'obj_path'),
        Index('idx_application_files_reference', 'tenant', 'internal_reference', 'version_no')
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True)
    tenant: Mapped[str] = mapped_column(String(255))
    version_no: Mapped[int] = mapped_column(Integer)
    internal_reference: Mapped[str] = mapped_column(String(255))
    external_reference: Mapped[Optional[str]] = mapped_column(String(255))
    screen_name: Mapped[Optional[str]] = mapped_column(String(255))
    key_name: Mapped[Optional[str]] = mapped_column(String(255))
    bucket_name: Mapped[Optional[str]] = mapped_column(String(255))
    obj_path: Mapped[str] = mapped_column(Text)
    internal_file_name_reference: Mapped[Optional[str]] = mapped_column(String(255))
    external_file_name_reference: Mapped[Optional[str]] = mapped_column(String(255))
    file_extension: Mapped[Optional[str]] = mapped_column(String(255))
    content_type: Mapped[Optional[str]] = mapped_column(String(255))
    uploaded_by_uuid: Mapped[Optional[str]] = mapped_column(String(255))
    uploaded_by: Mapped[Optional[str]] = mapped_column(String(255))
    uploaded_by_provider: Mapped[Optional[str]] = mapped_column(String(255))
    upload_timestamp: Mapped[datetime.datetime] = mapped_column(DateTime(timezone=True))
    file_upload_status: Mapped[Optional[str]] = mapped_column(CHAR(1), server_default=text("'N'::bpchar"))

    application: Mapped['Application'] = relationship('Application', back_populates='application_files')


class RoutingLog(Base):
    __tablename__ = 'routing_log'
    __table_args__ = (
        ForeignKeyConstraint(['route_condition_id'], ['routing_rules.route_condition_id'], ondelete='CASCADE',
                             name='fk_route_condition'),
        PrimaryKeyConstraint('id', name='routing_log_pkey'),
        Index('idx_routing_log_additional_attributes_gin', 'additional_attributes', postgresql_using='gin'),
        Index('idx_routing_log_destination_attributes_gin', 'destination_attributes', postgresql_using='gin'),
        Index('idx_routing_log_route_condition_id', 'route_condition_id'),
        Index('idx_routing_log_route_id', 'route_id'),
        Index('idx_routing_log_source_attributes_gin', 'source_attributes', postgresql_using='gin')
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True)
    tenant: Mapped[str] = mapped_column(String(255))
    source_attributes: Mapped[dict] = mapped_column(JSONB)
    destination_attributes: Mapped[dict] = mapped_column(JSONB)
    route_condition_id: Mapped[uuid.UUID] = mapped_column(UUID)
    additional_attributes: Mapped[Optional[dict]] = mapped_column(JSONB)
    route_id: Mapped[Optional[str]] = mapped_column(String(255))
    route_name: Mapped[Optional[str]] = mapped_column(String(255))
    action_code: Mapped[Optional[str]] = mapped_column(String(255))

    route_condition: Mapped['RoutingRules'] = relationship('RoutingRules', back_populates='routing_log')


class Subapplication(Base):
    __tablename__ = 'subapplication'
    __table_args__ = (
        CheckConstraint("display_in_queue::text = ANY (ARRAY['Y'::character varying, 'N'::character varying]::text[])",
                        name='subapplication_display_in_queue_check'),
        CheckConstraint(
            "file_upload_status::text = ANY (ARRAY['Y'::character varying, 'N'::character varying]::text[])",
            name='subapplication_file_upload_status_check'),
        ForeignKeyConstraint(['tenant', 'parent_reference', 'parent_version'],
                             ['application.tenant', 'application.internal_reference', 'application.version_no'],
                             name='subapplication_tenant_parent_reference_parent_version_fkey'),
        PrimaryKeyConstraint('id', name='subapplication_pkey'),
        UniqueConstraint('tenant', 'internal_reference', 'version_no', name='subapplication_reference_version_unique'),
        Index('idx_subapplication_additional_keys_gin', 'additional_keys', postgresql_using='gin'),
        Index('idx_subapplication_data_gin', 'data', postgresql_using='gin')
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True)
    tenant: Mapped[str] = mapped_column(String(255))
    internal_reference: Mapped[str] = mapped_column(String(255))
    version_no: Mapped[int] = mapped_column(Integer)
    application_type: Mapped[str] = mapped_column(String(255))
    customer_type: Mapped[str] = mapped_column(String(255))
    parent_reference: Mapped[str] = mapped_column(String(255))
    parent_version: Mapped[int] = mapped_column(Integer)
    external_reference: Mapped[Optional[str]] = mapped_column(String(255))
    kyc_reference: Mapped[Optional[str]] = mapped_column(String(255))
    onboarding_channel: Mapped[Optional[str]] = mapped_column(String(255))
    product_key: Mapped[Optional[str]] = mapped_column(String(255))
    product_name: Mapped[Optional[str]] = mapped_column(String(255))
    data: Mapped[Optional[dict]] = mapped_column(JSONB)
    additional_keys: Mapped[Optional[dict]] = mapped_column(JSONB)
    common_data: Mapped[Optional[dict]] = mapped_column(JSONB)
    additional_data: Mapped[Optional[dict]] = mapped_column(JSONB)
    file_upload_status: Mapped[Optional[str]] = mapped_column(String(1))
    user_role: Mapped[Optional[str]] = mapped_column(String(254))
    user_group: Mapped[Optional[str]] = mapped_column(String(254))
    primary_contact_number: Mapped[Optional[str]] = mapped_column(String(50))
    primary_email_address: Mapped[Optional[str]] = mapped_column(String(255))
    queue_code: Mapped[Optional[str]] = mapped_column(String(255))
    queue_name: Mapped[Optional[str]] = mapped_column(String(255))
    create_by: Mapped[Optional[str]] = mapped_column(String(255))
    create_by_uid: Mapped[Optional[str]] = mapped_column(String(255))
    create_by_provider: Mapped[Optional[str]] = mapped_column(String(255))
    create_timestamp: Mapped[datetime.datetime] = mapped_column(DateTime(timezone=True))
    last_action: Mapped[Optional[str]] = mapped_column(String(255))
    last_action_performed_by: Mapped[Optional[str]] = mapped_column(String(255))
    last_action_by_provider: Mapped[Optional[str]] = mapped_column(String(255))
    last_action_performed_by_uuid: Mapped[Optional[str]] = mapped_column(String(255))
    last_action_perform_timestamp: Mapped[Optional[datetime.datetime]] = mapped_column(DateTime(timezone=True))
    last_modified_by: Mapped[Optional[str]] = mapped_column(String(255))
    last_modified_by_provider: Mapped[Optional[str]] = mapped_column(String(255))
    last_modified_by_uuid: Mapped[Optional[str]] = mapped_column(String(255))
    last_modified_timestamp: Mapped[Optional[datetime.datetime]] = mapped_column(DateTime(timezone=True))
    submit_by: Mapped[Optional[str]] = mapped_column(String(255))
    submit_by_provider: Mapped[Optional[str]] = mapped_column(String(255))
    submit_by_uuid: Mapped[Optional[str]] = mapped_column(String(255))
    submit_timestamp: Mapped[Optional[datetime.datetime]] = mapped_column(DateTime(timezone=True))
    display_in_queue: Mapped[Optional[str]] = mapped_column(String(1))
    rejected_by: Mapped[Optional[str]] = mapped_column(String(255))
    rejected_by_provider: Mapped[Optional[str]] = mapped_column(String(255))
    rejected_by_uuid: Mapped[Optional[str]] = mapped_column(String(255))
    rejected_timestamp: Mapped[Optional[datetime.datetime]] = mapped_column(DateTime(timezone=True))
    discarded_by: Mapped[Optional[str]] = mapped_column(String(255))
    discarded_by_provider: Mapped[Optional[str]] = mapped_column(String(255))
    discarded_by_uuid: Mapped[Optional[str]] = mapped_column(String(255))
    discarded_timestamp: Mapped[Optional[datetime.datetime]] = mapped_column(DateTime(timezone=True))

    application: Mapped['Application'] = relationship('Application', back_populates='subapplication')
    subapplication_files: Mapped[List['SubapplicationFiles']] = relationship('SubapplicationFiles',
                                                                             back_populates='subapplication')


class SubapplicationFiles(Base):
    __tablename__ = 'subapplication_files'
    __table_args__ = (
        ForeignKeyConstraint(['tenant', 'internal_reference', 'version_no'],
                             ['subapplication.tenant', 'subapplication.internal_reference',
                              'subapplication.version_no'],
                             name='subapplication_files_tenant_internal_reference_version_no_fkey'),
        PrimaryKeyConstraint('id', name='subapplication_files_pkey'),
        Index('idx_subapplication_files_key_name', 'key_name'),
        Index('idx_subapplication_files_obj_path', 'obj_path'),
        Index('idx_subapplication_files_reference', 'tenant', 'internal_reference', 'version_no')
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True)
    tenant: Mapped[str] = mapped_column(String(255))
    version_no: Mapped[int] = mapped_column(Integer)
    internal_reference: Mapped[Optional[str]] = mapped_column(String(255))
    external_reference: Mapped[Optional[str]] = mapped_column(String(255))
    screen_name: Mapped[Optional[str]] = mapped_column(String(255))
    key_name: Mapped[Optional[str]] = mapped_column(String(255))
    bucket_name: Mapped[Optional[str]] = mapped_column(String(255))
    obj_path: Mapped[Optional[str]] = mapped_column(Text)
    internal_file_name_reference: Mapped[Optional[str]] = mapped_column(String(255))
    external_file_name_reference: Mapped[Optional[str]] = mapped_column(String(255))
    file_extension: Mapped[Optional[str]] = mapped_column(String(255))
    content_type: Mapped[Optional[str]] = mapped_column(String(255))
    uploaded_by_uuid: Mapped[Optional[str]] = mapped_column(String(255))
    uploaded_by: Mapped[Optional[str]] = mapped_column(String(255))
    uploaded_by_provider: Mapped[Optional[str]] = mapped_column(String(255))
    upload_timestamp: Mapped[datetime.datetime] = mapped_column(DateTime(timezone=True))
    file_upload_status: Mapped[Optional[str]] = mapped_column(CHAR(1), server_default=text("'N'::bpchar"))

    subapplication: Mapped['Subapplication'] = relationship('Subapplication', back_populates='subapplication_files')