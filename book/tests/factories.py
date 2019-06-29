from book.store.repos.address import AddressRepo
from book.store.repos.document_entity_mapping import EntityMandatoryDocumentsRepo
from book.store.repos.document_status_partners import PartnersDocumentVerificationRepo
from book.store.repos.partner_document_mapping import PartnerMandatoryDocumentRepo
from book.store.repos.status_flow import StatusFlowRepo
from book.store.repos.vehicle_gps_device_mapping import VehicleGpsDeviceRepo
from book.store.repos.vehicle_company_details import VehicleCompanyDetailsRepo
from book.store.repos.vehicle_partner_site_mapping import VehiclePartnerRepo
from book.store.repos.vehicle_detail import VehicleDetailRepo
from book.store.repos.escort_partner_mapping import EscortPartnerRepo
from book.store.repos.driver_partner_mapping import DriverPartnerRepo
from book.store.repos.vehicle_document import VehicleDocumentRepo
from book.store.repos.person_document import PersonDocumentRepo

from book.domain.models.documenttype import (
    DocumentType,
    PersonDocument,
    VehicleDocument,
    EntityMandatoryDocuments,
    PartnerMandatoryDocument,
    PartnersDocumentVerification,
)
from book.domain.models.vehicle import (
    Vehicle,
    VehicleDetail,
    VehiclePartner,
    VehicleCompanyDetail,
    VehicleGpsDevice,
    VehiclePerson,
)
from book.store.repos.document import DocumentTypeRepo

from book.store.repos.vehicle import VehicleRepo

from book.domain.models.book import State, District, Address
from book.store.repos.district import DistrictRepo
from book.store.repos.state import StateRepo

from book.domain.models.driver import Driver, DriverPartner

from book.store.repos.driver import DriverRepo

from book.domain.models.escort import Escort, EscortPartner

from book.store.repos.escort import EscortRepo

from book.store.repos.person_role import PersonRoleRepo

from book.domain.models.application import StatusFlow

from book.domain.models.person import Person, PersonRole

from book.store.repos.person import PersonRepo
from book.store.repos.vehicle_person_mapping import VehiclePersonRepo

from book.utils.custom_enums import (
    VehicleOnboardingStatus,
    PersonRoleEnum,
    PersonOnboardingStatus,
    DocumentCategory,
    B2BDocumentEntity,
    DocumentStatus,
)
from book.utils.custom_enums import ENTITY, FileStatus, ValidationType


def create_person(person_name="dummy-person", mobile="9876543210"):
    return PersonRepo().create(Person(person_name=person_name, mobile_number=mobile))


def create_person_role_with_status(
    person: Person, status: PersonOnboardingStatus, role: PersonRoleEnum
):
    return PersonRoleRepo().create(
        PersonRole(person_id=person.id, status=status, role=role)
    )


def create_vehicle_partner_mapping(vehicle, partner_site_id):
    return VehiclePartnerRepo().create(
        VehiclePartner(partner_site_id=partner_site_id, vehicle_id=vehicle.id)
    )


def create_partner_doc_verification(
    document_id, partner_site_id, status, entity_type, issue_type, issue_comment
):
    return PartnersDocumentVerificationRepo().create(
        PartnersDocumentVerification(
            document_id=document_id,
            partner_site_id=partner_site_id,
            status=status,
            entity_type=entity_type,
            issue_type=issue_type,
            issue_comment=issue_comment,
        )
    )


def create_escort_lead(person):
    person_role = create_person_role_with_status(
        person, PersonOnboardingStatus.LEAD, PersonRoleEnum.ESCORT
    )
    person_2 = create_person("test_operator", "7678768788")
    operator_person_role = create_person_role_with_status(
        person_2, PersonOnboardingStatus.ACTIVE, PersonRoleEnum.OPERATOR
    )
    return EscortRepo().create(
        Escort(
            person_role_id=person_role.id,
            operator_person_role_id=operator_person_role.id,
        )
    )


def create_escort(escort_role: PersonRole, operator_role: PersonRole):
    return EscortRepo().create(
        Escort(person_role_id=escort_role.id, operator_person_role_id=operator_role.id)
    )


def create_driver_lead(person):
    person_role = create_person_role_with_status(
        person, PersonOnboardingStatus.LEAD, PersonRoleEnum.DRIVER
    )
    person_2 = create_person("test_operator", "7678768788")
    operator_person_role = create_person_role_with_status(
        person_2, PersonOnboardingStatus.ACTIVE, PersonRoleEnum.OPERATOR
    )
    return DriverRepo().create(
        Driver(
            person_role_id=person_role.id,
            operator_person_role_id=operator_person_role.id,
            cid="CID83478",
            is_trained=True,
        )
    )


def create_driver(driver_person_role: PersonRole, operator_person_role: PersonRole):
    return DriverRepo().create(
        Driver(
            person_role_id=driver_person_role.id,
            operator_person_role_id=operator_person_role.id,
            cid="CID83478",
            is_trained=True,
        )
    )


def create_driver_partner_mapping(driver, partner_site_id):
    return DriverPartnerRepo().create(
        DriverPartner(
            partner_site_id=partner_site_id, driver_person_role_id=driver.person_role_id
        )
    )


def create_escort_partner_mapping(escort: Escort, partner_site_id):
    return EscortPartnerRepo().create(
        EscortPartner(
            partner_site_id=partner_site_id, escort_person_role_id=escort.person_role_id
        )
    )


def create_partner_doc_mapping(
    document_type_id, partner_site_id, entity_type: B2BDocumentEntity
):
    return PartnerMandatoryDocumentRepo().create(
        PartnerMandatoryDocument(
            entity_type=entity_type,
            partner_site_id=partner_site_id,
            document_type_id=document_type_id,
        )
    )


def create_vehicle_person_mapping(vehicle, person_role: PersonRole):
    return VehiclePersonRepo().create(
        VehiclePerson(person_role_id=person_role.id, vehicle_id=vehicle.id)
    )


def create_state():
    return StateRepo().create(
        State(state_name="dummy", gst_code="DUMMY", state_code="DUMMY")
    )


def create_district(state: State):
    return DistrictRepo().create(District(district_name="dummy", state_id=state.id))


def create_address(state: State, district: District, formatted_address: str):
    return AddressRepo().create(
        Address(
            district_id=district.id,
            state_id=state.id,
            formatted_address=formatted_address,
        )
    )


def create_vehicle(
    status: VehicleOnboardingStatus,
    registration_number="dummy",
    passenger_seating_capacity=10,
):
    return VehicleRepo().create(
        Vehicle(
            registration_number=registration_number,
            passenger_seating_capacity=passenger_seating_capacity,
            status=status,
        )
    )


def create_status_flow(status: str, next_status: str, entity):
    return StatusFlowRepo().create(
        StatusFlow(status=status, next_status=next_status, entity=entity)
    )


def create_document_entity_mapping(
    document_category: DocumentCategory,
    entity,
    validation_type: ValidationType = ValidationType.ANY,
):
    return EntityMandatoryDocumentsRepo().create(
        EntityMandatoryDocuments(
            entity=entity,
            document_category=document_category,
            validation_type=validation_type,
        )
    )


def create_vehicle_gps_device_mapping(device, vehicle):
    return VehicleGpsDeviceRepo().create(
        VehicleGpsDevice(
            vehicle_id=vehicle.id, gps_device=device, gps_device_imei="34938940839024"
        )
    )


def create_vehicle_details(vehicle):
    return VehicleDetailRepo().create(
        VehicleDetail(vehicle_id=vehicle.id, display_name="dummy")
    )


def create_document(
    doc_category: DocumentCategory,
    fields: dict,
    document_type_name="dummy",
    code="DUMMY",
    entity: ENTITY = ENTITY.VEHICLE,
):
    return DocumentTypeRepo().create(
        DocumentType(
            document_type_name=document_type_name,
            code=code,
            entity=entity,
            document_category=doc_category,
            document_fields=fields,
        )
    )


def create_person_document(
    person: Person, document: DocumentType, document_url=None, document_value=None
):
    if document_url is None:
        document_url = [{"url": "dummy_url", "resource_type": "image/jpeg"}]
    if document_value is None:
        document_value = "dummy_value"
    return PersonDocumentRepo().create(
        PersonDocument(
            person_id=person.id,
            document_type_id=document.id,
            document_value=document_value,
            document_url=document_url,
            file_status=FileStatus.VERIFIED,
            document_status=DocumentStatus.VERIFIED,
        )
    )


def create_vehicle_document(
    vehicle: Vehicle, document: DocumentType, document_url=None, document_value=None
):
    if document_url is None:
        document_url = [{"url": "dummy_url", "resource_type": "image/jpeg"}]
    if document_value is None:
        document_value = "dummy_value"
    return VehicleDocumentRepo().create(
        VehicleDocument(
            vehicle_id=vehicle.id,
            document_type_id=document.id,
            document_value=document_value,
            document_url=document_url,
            file_status=FileStatus.VERIFIED,
        )
    )


def create_vehicle_company_details(model, manufacturer):
    return VehicleCompanyDetailsRepo().create(
        VehicleCompanyDetail(model=model, manufacturer=manufacturer)
    )
