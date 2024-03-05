// api
import ValidateCommon from "Shared/ts/api/validate/validate-common";

// applications
import {
    initializeValidateCommon,
    initializeValidateCommonWithStripe
} from "Shared/ts/applications/form";

// components
import StatusScreen from "Shared/ts/components/status-screen";

// interfaces
import { IValidateCommonErrorResponse } from "Shared/ts/interfaces/validate/validate-common";
import { ICartChange } from "Shared/ts/interfaces/cart-change";

type ActionCode = HTMLInputElement;
type ActionQuantity = HTMLSelectElement | HTMLInputElement;
type DataProductCode = HTMLButtonElement;

export default class OrderForm {
    public validateCommon: ValidateCommon;

    public actionQuantities: ActionQuantity[];

    public actionCodes: ActionCode[];

    public dataProductCodes: HTMLButtonElement[];

    public productCodes: string[];

    public actionQuantityActionCodeMap: WeakMap<ActionQuantity, ActionCode>;

    public actionCodeActionQuantityMap: WeakMap<ActionCode, ActionQuantity>;

    private userActivateStatus: boolean = false;

    public cartStatusScreen: Promise<StatusScreen>;

    constructor() {
        this.validateCommon =
            initializeValidateCommonWithStripe() ?? initializeValidateCommon();
        this.initializeStatusScreen();

        this.dataProductCodes = Array.from<HTMLButtonElement>(
            document.querySelectorAll("[data-product-code]")
        );

        this.actionCodes = this.validateCommon.inputs.filter((input) =>
            input.name.match(/ActionCode/)
        );

        this.actionQuantities = this.validateCommon.comboboxes.filter(
            (combobox) => combobox.name.match(/ActionQuantity/)
        );

        this.productCodes = this.dataProductCodes
            .map((dataProductCodes) =>
                dataProductCodes.getAttribute("data-product-code")
            )
            .filter((productCode): productCode is string => !!productCode);

        this.actionCodeActionQuantityMap =
            this.createActionCodeActionQuantityMap(this.actionCodes);

        this.actionQuantityActionCodeMap =
            this.createActionQuantityActionCodeMap(this.actionQuantities);

        this.cartStatusScreen = this.initializeCartStatusScreen();
    }

    private async initializeCartStatusScreen(): Promise<StatusScreen> {
        const reviewTable =
            this.validateCommon.form?.querySelector<HTMLElement>(
                "#order-table"
            );
        if (!reviewTable) {
            throw {
                message: `The HTMLElement that surrounds the order form review table could not be found in the document using the following identity`,
                id: "order-table"
            };
        }

        return new StatusScreen("review-table", reviewTable);
    }

    private initializeStatusScreen(): void {
        if (!this.validateCommon.form) return;

        const statusScreen = new StatusScreen(
            "checkout-form",
            this.validateCommon.form
        );
        statusScreen.update("Initializing payment options");

        let closeConnection = false;
        let timeout: NodeJS.Timeout;

        const initializeTimeout = (time: number) =>
            setTimeout(() => {
                closeConnection = true;

                clearTimeout(timeout);

                statusScreen.update("Ready for use");
            }, time);

        addEventListener("load", (event) => initializeTimeout(0));
    }

    public createActionQuantityActionCodeMap(
        actionQuantities: ActionQuantity[]
    ): WeakMap<ActionQuantity, ActionCode> {
        const map = new WeakMap<ActionQuantity, ActionCode>();

        actionQuantities
            .map((actionQuantity) => {
                return {
                    actionQuantity,
                    actionCode: (() => {
                        const index =
                            actionQuantity.name.match(/(?<index>\d$)/)?.groups
                                ?.index;
                        if (!index) return;

                        return this.validateCommon.form?.querySelector(
                            `input[type="hidden"][name="ActionCode${index}"]`
                        );
                    })()
                };
            })
            .filter(
                (
                    group
                ): group is {
                    actionQuantity: ActionQuantity;
                    actionCode: ActionCode;
                } => !!group.actionCode
            )
            .forEach((group) => {
                map.set(group.actionQuantity, group.actionCode);
            });

        return map;
    }

    public createActionCodeActionQuantityMap(
        actionCodes: ActionCode[]
    ): WeakMap<ActionCode, ActionQuantity> {
        const map = new WeakMap<ActionCode, ActionQuantity>();

        actionCodes
            .map((actionCode) => {
                return {
                    actionCode,
                    actionQuantity: (() => {
                        const index =
                            actionCode.name.match(/(?<index>\d$)/)?.groups
                                ?.index;
                        if (!index) return;

                        return this.validateCommon.form?.querySelector(
                            `[name="ActionQuantity${index}"]`
                        );
                    })()
                };
            })
            .filter(
                (
                    group
                ): group is {
                    actionCode: ActionCode;
                    actionQuantity: ActionQuantity;
                } => !!group.actionQuantity
            )
            .forEach((group) => {
                map.set(group.actionCode, group.actionQuantity);
            });

        return map;
    }

    public getActionQuantityByActionCode(
        actionCode: ActionCode
    ): ActionQuantity | undefined {
        const actionQuantity = this.actionCodeActionQuantityMap.get(actionCode);
        if (!actionQuantity) return;

        return actionQuantity;
    }

    public getActionCodeByActionQuantity(
        actionQuantity: ActionQuantity
    ): ActionCode | undefined {
        const actionCode = this.actionQuantityActionCodeMap.get(actionQuantity);
        if (!actionCode) return;

        return actionCode;
    }

    public async handleOfferChange() {
        const statusScreen = await this.cartStatusScreen;

        this.dataProductCodes.forEach((dataProductCode) =>
            dataProductCode.addEventListener("click", (event) => {
                const productCode =
                    dataProductCode.getAttribute("data-product-code");
                if (!productCode) return;

                if (
                    window._dtmShoppingCart
                        .SearchItems(productCode)
                        .find((i) => i.id === productCode)
                )
                    return;

                statusScreen.busy("Updating order");
            })
        );

        window.addEventListener(
            "CartChange",
            (event: CustomEvent<ICartChange>) => {
                statusScreen.close();
            }
        );
    }

    public validateOffers() {
        const offerControl = document.querySelector(
            "#select-offer-error-anchor"
        );
        if (!offerControl) return;

        this.validateCommon.controlTargets.push(offerControl);

        const offerErrorMessage = document.querySelector(
            "#select-offer-error-message"
        );
        if (!offerErrorMessage) return;

        this.dataProductCodes.forEach((dataProductCode) =>
            dataProductCode.addEventListener("click", (event) => {
                if (this.userActivateStatus) return;

                this.userActivateStatus = true;
            })
        );

        window.addEventListener(
            "CartChange",
            (event: CustomEvent<ICartChange>) => {
                if (!this.userActivateStatus) return;

                const items = event.detail.items;

                const valid = items.some((item) =>
                    this.productCodes.includes(item.code)
                );

                valid
                    ? this.validateCommon.setControlToDefault(offerControl)
                    : this.validateCommon.setControlToInvalid(offerControl);
            }
        );

        window.onFormPreValidation = (
            event
        ): IValidateCommonErrorResponse[] => {
            const errors: IValidateCommonErrorResponse[] = [];

            const items = window._dtmShoppingCart.Items();

            const hasItem = items.some(
                (item) => this.productCodes.includes(item.id) && item.qty > 0
            );

            if (hasItem) return errors;

            errors.push({
                element: $(offerControl),
                message:
                    offerErrorMessage.textContent?.trim() ??
                    "Please select an offer."
            });

            return errors;
        };
    }
}
