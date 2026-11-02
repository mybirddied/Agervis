/**
 * Property Management System
 * Ownership, rentals, and access control
 */

export type PropertyType = 'apartment' | 'house' | 'business' | 'warehouse' | 'safehouse';

export interface Property {
  id: string;
  type: PropertyType;
  location: string;
  owner: string;
  purchasePrice: number;
  currentValue: number;
  rentIncome: number; // per day
  occupants: string[];
  accessList: string[];
  furniture: string[];
  security: {
    locks: number; // 0-10
    cameras: number; // 0-10
    alarm: boolean;
  };
  condition: number; // 0-100
}

export interface PropertyLease {
  id: string;
  propertyId: string;
  tenant: string;
  rentPerDay: number;
  startDate: number;
  endDate: number;
  active: boolean;
}

export class PropertyManager {
  private properties: Map<string, Property> = new Map();
  private leases: Map<string, PropertyLease> = new Map();

  /**
   * Purchase a property
   */
  purchaseProperty(
    type: PropertyType,
    location: string,
    owner: string,
    price: number
  ): Property {
    const propertyId = `prop_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    const property: Property = {
      id: propertyId,
      type,
      location,
      owner,
      purchasePrice: price,
      currentValue: price,
      rentIncome: this.calculateBaseRentIncome(type),
      occupants: [owner],
      accessList: [owner],
      furniture: [],
      security: {
        locks: 2,
        cameras: 0,
        alarm: false,
      },
      condition: 100,
    };
    this.properties.set(propertyId, property);
    return property;
  }

  /**
   * Upgrade security
   */
  upgradeSecurity(propertyId: string, type: 'locks' | 'cameras' | 'alarm', cost: number): boolean {
    const property = this.properties.get(propertyId);
    if (!property) return false;

    if (type === 'locks' && property.security.locks < 10) {
      property.security.locks++;
    } else if (type === 'cameras' && property.security.cameras < 10) {
      property.security.cameras++;
    } else if (type === 'alarm') {
      property.security.alarm = true;
    }

    return true;
  }

  /**
   * Lease property to tenant
   */
  leaseProperty(propertyId: string, tenant: string, rentPerDay: number, durationDays: number): PropertyLease | null {
    const property = this.properties.get(propertyId);
    if (!property) return null;

    const lease: PropertyLease = {
      id: `lease_${Date.now()}`,
      propertyId,
      tenant,
      rentPerDay,
      startDate: Date.now(),
      endDate: Date.now() + durationDays * 24 * 60 * 60 * 1000,
      active: true,
    };

    this.leases.set(lease.id, lease);
    property.occupants.push(tenant);
    property.accessList.push(tenant);

    return lease;
  }

  /**
   * Grant access to property
   */
  grantAccess(propertyId: string, personId: string): boolean {
    const property = this.properties.get(propertyId);
    if (!property) return false;

    if (!property.accessList.includes(personId)) {
      property.accessList.push(personId);
    }
    return true;
  }

  /**
   * Revoke access from property
   */
  revokeAccess(propertyId: string, personId: string): boolean {
    const property = this.properties.get(propertyId);
    if (!property) return false;

    property.accessList = property.accessList.filter((p) => p !== personId);
    return true;
  }

  /**
   * Calculate base rent income for property type
   */
  private calculateBaseRentIncome(type: PropertyType): number {
    const baseRents: Record<PropertyType, number> = {
      apartment: 150,
      house: 300,
      business: 500,
      warehouse: 1000,
      safehouse: 0, // no rental income
    };
    return baseRents[type] || 100;
  }

  /**
   * Get property by ID
   */
  getProperty(propertyId: string): Property | null {
    return this.properties.get(propertyId) || null;
  }

  /**
   * Get properties owned by player
   */
  getPropertiesByOwner(owner: string): Property[] {
    return Array.from(this.properties.values()).filter((p) => p.owner === owner);
  }

  /**
   * Calculate total property value for owner
   */
  getTotalPropertyValue(owner: string): number {
    const properties = this.getPropertiesByOwner(owner);
    return properties.reduce((sum, p) => sum + p.currentValue, 0);
  }
}
