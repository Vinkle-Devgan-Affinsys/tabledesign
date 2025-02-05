from rest_framework import status
from rest_framework.response import Response
from sqlalchemy import select, text, insert
from client_metadata.fcbsmartbranch.src.tables.postgresql.models import Session
from client_metadata.fcbsmartbranch.src.db_connection.synchronous.connect import get_client_system_base_engine
from datetime import datetime, date
import uuid
import logging
from pydantic import ValidationError
from pydantic import BaseModel, validator, root_validator
from typing import Dict, Optional

logger = logging.getLogger(__name__)

class SessionRequest(BaseModel):
    branch_id: str
    customer_rep: Optional[str] = None
    authentication_method: Optional[str] = None
    cif: str
    account_dict: Dict
    userid: str
    approver_provider: str
    username: str
    representative_data: Optional[Dict] = {}

    @validator('customer_rep')
    def validate_customer_rep(cls, v):
        if v and v not in ['C', 'R']:
            raise ValueError("customer_rep must be either C or R")
        return v

    @validator('authentication_method')
    def validate_authentication_method(cls, v):
        allowed_methods = ['Card', 'CIF', 'Phone Number', 'Account number', 'NID', 'Passport', 'DL']
        if v and v not in allowed_methods:
            raise ValueError(f"authentication_method allowed -> {allowed_methods}")
        return v

    @validator('account_dict')
    def validate_account_dict(cls, v):
        if not isinstance(v, dict):
            raise ValueError("account_dict should be a dict")
        return v

    @root_validator(pre=False,skip_on_failure=True)
    def validate_representative_data(cls, values):
        customer_rep = values.get('customer_rep')
        representative_data = values.get('representative_data')

        if customer_rep == 'R':
            # required_fields = ["id_no", "first_name", "last_name", "dob", "gender"]
            ###
            required_fields = {
                "id_no" : str,
                "first_name" : str,
                "last_name" : str,
                "dob" : date,
                "gender" : str,
            }
            if not representative_data:
                raise ValueError("representative_data must be provided")
            for field, expected_type in required_fields.items():
                if field not in representative_data:
                    raise ValueError(f"representative_data must contain {field}")
                ###
                if field == "dob" and isinstance(representative_data[field], str):
                    try:
                        representative_data[field] = datetime.strptime(representative_data[field], "%Y-%m-%d").date()
                    except ValueError:
                        raise ValueError("dob must be in 'YYYY-MM-DD' format")
                if not isinstance(representative_data[field], expected_type):
                    raise ValueError(f"Field '{field}' must be of type {expected_type.__name__}")

        return values

def callback(request, **kwargs):
    try:
        schema, engine = get_client_system_base_engine(tenant="fcbsmartbranch")

        if not schema:
            logger.exception(f"Schema is not defined")
            return Response({"success": False, "error": "Schema is not defined"}, status=status.HTTP_400_BAD_REQUEST)

        try:
            session_data = SessionRequest(**request.data)
        except ValidationError as e:
            logger.error(f"Validation failed: {e}")
            return Response({"success": False, "error": f"Invalid input data"}, status=status.HTTP_400_BAD_REQUEST)

        session_id = str(uuid.uuid4())

        new_session = {
            "branch_id": session_data.branch_id,
            "session_id": session_id,
            "customer_rep": session_data.customer_rep,
            "authentication_method": session_data.authentication_method,
            "cif": session_data.cif,
            "account_no": session_data.account_dict,
            "session_start": datetime.now(),
            "session_end": None,
            "userid": session_data.userid,
            "approver_provider": session_data.approver_provider,
            "username": session_data.username,
            "representative_data": session_data.representative_data,
        }

        stmt1 = insert(Session).values(new_session)
        stmt2 = select(Session)

        with engine.connect() as connection:
            transaction = connection.begin()
            try:

                connection.execute(text(f"SET SEARCH_PATH TO {schema}"))

                connection.execute(stmt1)

                result = connection.execute(stmt2)

                row = result.first()

                if row:
                    logger.info(f"Session created successfully: {row}")
                else:
                    logger.info("No session data returned.")

                transaction.commit()
                logger.info("Transaction committed successfully")

            except Exception as e:
                transaction.rollback()
                logger.error(f"Transaction rolled back {e}")

        return Response({"success": True}, status=status.HTTP_200_OK)

    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        return Response({"success": False, "error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)