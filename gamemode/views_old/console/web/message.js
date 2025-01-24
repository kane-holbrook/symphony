class ExpandableMessage extends HTMLElement {
    constructor() {
        super();
        const shadow = this.attachShadow({ mode: 'open' });

        // Create styles
        const style = document.createElement('style');
        style.textContent = `
            .container {
                display: flex;
                flex-direction: column;
                width: 100%;
                padding: 0.25ch;
                background-color: var(--background-color, #333);
                border-bottom: 1px solid #444;
            }
            .message {
                display: flex;
                flex-direction: row;
            }
            .expand {
                padding-left:1ch;
                cursor: pointer;
                color: white;
                width: 3ch;
                user-select: none;
                align-items: center;
                display: flex;
            }
            .expand.hidden {
                visibility: hidden;
            }
            .timestamp {
                color: #aaa;
                width: 20ch;
                align-items: center;
                display: flex;
            }
            .type {
                color: white;
                font-weight: bold;
                display: flex;
                align-items: center;
                min-width: 20ch;
            }
            .realm {
                color: white;
                font-weight: bold;
                display: flex;
                align-items: center;
                width: 10ch;
            }
            .data {
                display: none;
                color: #aaa;
                margin-top: 0.5ch;
                flex: 1;
                padding-left:4ch;
            }
            .data.visible {
                display: block;
            }
            ::slotted(pre) {
                background: #222;
                padding: 0.5ch;
                border-radius: 4px;
                font-family: monospace;
                color: #ddd;
            }
        `;

        // Create structure
        const container = document.createElement('div');
        container.innerHTML = `
            <div class="container">
                <div class="message">
                    <div class="expand">+</div>
                    <div class="timestamp"></div>
                    <div class="realm"></div>
                    <div class="type"></div>
                    <slot name="content" class="content"></slot>
                </div>
                <div class="data"><slot name="data"></slot></div>
            </div>
        `;

        shadow.append(style, container);

        // Add toggle functionality
        container.querySelector('.expand').addEventListener('click', () => {
            const dataElement = container.querySelector('.data');
            const isVisible = dataElement.classList.toggle('visible');
            container.querySelector('.expand').textContent = isVisible ? '-' : '+';
        });

        // Update attributes dynamically
        this.updateAttributes(container);
    }

    static get observedAttributes() {
        return ['timestamp', 'type', 'realm'];
    }

    attributeChangedCallback(name, oldValue, newValue) {
        this.updateAttributes(this.shadowRoot);
    }

    updateAttributes(shadow) {
        const timestampElement = shadow.querySelector('.timestamp');
        const typeElement = shadow.querySelector('.type');
        const realmElement = shadow.querySelector('.realm');
        const expandElement = shadow.querySelector('.expand');
        const dataSlot = shadow.querySelector('slot[name="data"]');

        timestampElement.textContent = this.getAttribute('timestamp') || '';
        typeElement.textContent = this.getAttribute('type') || '';
        realmElement.textContent = this.getAttribute('realm') || '';

        if (dataSlot) {
            const assignedNodes = dataSlot.assignedNodes().filter(node => node.nodeType === Node.ELEMENT_NODE || node.nodeType === Node.TEXT_NODE);
            if (assignedNodes.length > 0) {
                expandElement.classList.remove('hidden');
            } else {
                expandElement.classList.add('hidden');
            }
        }
    }
}

// Define the component
customElements.define('con-msg', ExpandableMessage);
