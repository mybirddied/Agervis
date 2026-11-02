// Room Templates - Presets for common room types
// Office, apartment, street, alley with default tile layouts

import type { RoomTemplate, TilePlacement } from '../../shared/types/map-editor';

export class RoomTemplateManager {
  private templates: Map<string, RoomTemplate> = new Map();

  constructor() {
    this.initializeDefaultTemplates();
  }

  /**
   * Initialize built-in room templates
   */
  private initializeDefaultTemplates(): void {
    const templates: RoomTemplate[] = [
      {
        id: 'template_office',
        name: 'Office',
        description: 'Standard office room with desk, chair, filing cabinet',
        width: 12,
        height: 10,
        category: 'office',
        defaultTiles: [
          // This would be populated with actual tile IDs in production
          // Placeholder structure shown here
        ],
      },
      {
        id: 'template_apartment',
        name: 'Apartment',
        description: 'Small apartment with furniture and living space',
        width: 14,
        height: 12,
        category: 'apartment',
        defaultTiles: [],
      },
      {
        id: 'template_street',
        name: 'Street',
        description: 'Urban street with buildings and sidewalk',
        width: 20,
        height: 8,
        category: 'street',
        defaultTiles: [],
      },
      {
        id: 'template_alley',
        name: 'Alley',
        description: 'Narrow alley between buildings',
        width: 8,
        height: 16,
        category: 'alley',
        defaultTiles: [],
      },
    ];

    templates.forEach((template) => {
      this.templates.set(template.id, template);
    });
  }

  /**
   * Get a template by ID
   */
  getTemplate(templateId: string): RoomTemplate | undefined {
    return this.templates.get(templateId);
  }

  /**
   * Get all available templates
   */
  getAllTemplates(): RoomTemplate[] {
    return Array.from(this.templates.values());
  }

  /**
   * Get templates by category
   */
  getTemplatesByCategory(category: string): RoomTemplate[] {
    return Array.from(this.templates.values()).filter((t) => t.category === category);
  }

  /**
   * Create a custom template
   */
  createCustomTemplate(
    id: string,
    name: string,
    description: string,
    width: number,
    height: number,
    defaultTiles: TilePlacement[]
  ): RoomTemplate {
    const template: RoomTemplate = {
      id,
      name,
      description,
      width,
      height,
      category: 'custom',
      defaultTiles,
    };

    this.templates.set(id, template);
    return template;
  }

  /**
   * Save template to storage (for persistence)
   */
  exportTemplate(templateId: string): RoomTemplate | null {
    return this.templates.get(templateId) || null;
  }

  /**
   * Load template from storage
   */
  importTemplate(template: RoomTemplate): void {
    this.templates.set(template.id, template);
  }
}

export default RoomTemplateManager;
