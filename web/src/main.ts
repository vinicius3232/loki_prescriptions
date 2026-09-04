import { nuifetch } from './fetch';
import './styles/main.css';
import './styles/de.css';
import './styles/us.css';
import './styles/uk.css';

var Config = { // is detected by lua config, don't change here
    nui_style: "us",
    locale: "en-US",
	firstMed: "",
	medicines: [] as string[],
};

var creating: boolean = true;
let medications: { label: string, amount: number }[] = [];

function renderMedicationRows(): void {
    const rows = $(".medication-rows").empty();
    medications.forEach((medication, index) => {
        const options = Config.medicines.map((label) =>
            `<option ${label === medication.label ? "selected" : ""}>${label}</option>`
        ).join("");
        rows.append(`
            <div class="medication-row" data-index="${index}">
                <input class="medication-amount" type="number" min="1" value="${medication.amount}">
                <span class="medication-times">x</span>
                <select class="medication-choice">${options}</select>
                <button type="button" class="medication-remove" aria-label="Remove medication">&minus;</button>
            </div>
        `);
    });
}

function updateMedicationSummary(): void {
    const summary = medications.map((medication) => `${medication.amount}x ${medication.label}`).join(", ");
    $("#medication").val(summary);
}

function setMedications(next: { label: string, amount: number }[]): void {
    medications = next.length ? next : [{ label: Config.firstMed, amount: 1 }];
    renderMedicationRows();
    updateMedicationSummary();
}

function openMedicationPicker(): void {
    renderMedicationRows();
    $(".med-picker").addClass("is-open").attr("aria-hidden", "false");
}

function closeMedicationPicker(): void {
    $(".med-picker").removeClass("is-open").attr("aria-hidden", "true");
    updateMedicationSummary();
}

$(document).on("keydown", function(e: KeyboardEvent) {
    if (e.key === "Escape") {
        $("body").hide();
        nuifetch("nuiClosed");
    }
});

$(document).on('ready', function () {
    $("body").hide();

	window.addEventListener("message", function (e) {
		switch (e.data.event) {
            case "load_config":
                Config.nui_style = e.data.style;
                Config.locale = e.data.locale;
                $("#cancel").text(e.data.label_cancel);
                $("#submit").text(e.data.label_submit);

                // remove all unused prescription styles
                $(".main").each(function(this: HTMLElement, _index: number, _element: HTMLElement): void {
                    let e = $(this);
                    if (!e.hasClass(`${Config.nui_style}-main`) && !e.hasClass("med-picker")) { // TODO: TEMPORARY FOR DEV
                        e.remove();
                    };
                })

                Config.medicines = e.data.medicine.map((medicine: { label: string }) => medicine.label);
                Config.firstMed = Config.medicines[0] || "";
                setMedications([]);

				const btn_submit = document.getElementById('submit');
				if (btn_submit) {
					btn_submit.removeEventListener('click', SubmitPrescription);
					btn_submit.addEventListener('click', SubmitPrescription);
				}

				const btn_cancel = document.getElementById('cancel');
				if (btn_cancel) {
					btn_cancel.removeEventListener('click', CancelPrescription);
					btn_cancel.addEventListener('click', CancelPrescription);
				}
                $(".medication-open").off("click").on("click", openMedicationPicker);
                $(".med-picker-close, .med-picker-done").off("click").on("click", closeMedicationPicker);
                $(".medication-add").off("click").on("click", function () {
                    medications.push({ label: Config.firstMed, amount: 1 });
                    renderMedicationRows();
                });
                $(".medication-rows").off("change", ".medication-choice, .medication-amount").on("change", ".medication-choice, .medication-amount", function (this: HTMLElement) {
                    const row = $(this).closest(".medication-row");
                    const index = Number(row.data("index"));
                    medications[index].label = row.find(".medication-choice").val() as string;
                    medications[index].amount = Math.max(1, Number(row.find(".medication-amount").val()) || 1);
                    updateMedicationSummary();
                });
                $(".medication-rows").off("click", ".medication-remove").on("click", ".medication-remove", function (this: HTMLElement) {
                    medications.splice(Number($(this).closest(".medication-row").data("index")), 1);
                    if (!medications.length) medications.push({ label: Config.firstMed, amount: 1 });
                    renderMedicationRows();
                    updateMedicationSummary();
                });

                break;

            case "open_nui":
                if (!creating) {
                    CancelPrescription(null, true);
                    creating = true;
                    $(".data").each(function(this: HTMLElement, _index: number, _element: HTMLElement): void {
                        const elem = document.getElementById($(this).attr("id")) as HTMLInputElement;
                        elem.readOnly = false;
                        elem.disabled = false; // for the select elem
                    });
                    $(".medication-open").show();
                    $(".buttons").show();
                } else {
                    $(".data").each(function(this: HTMLElement, _index: number, _element: HTMLElement): void {
                        const elem = document.getElementById($(this).attr("id")) as HTMLInputElement;
                        elem.readOnly = false;
                        elem.disabled = false; // for the select elem
                    });
                    $(".medication-open").show();
                };
                $("#date").text(GetDateString());
                $("body").show();
                break;

            case "close_nui":
                $("body").hide();
                break;

            case "show_prescription":
                creating = false;
                $(".buttons").hide();
                $(".medication-open").hide();
                $(".data").each(function(this: HTMLElement, _index: number, _element: HTMLElement): void {
                    const elem = $(this);
                    const id: string = elem.attr("id");
                    elem.val(e.data.prescription[id]);

                    const inputelem = document.getElementById($(this).attr("id")) as HTMLInputElement;
                    inputelem.readOnly = true;
                    inputelem.disabled = true; // for the select elem
                });
                setMedications(e.data.prescription.medications || (e.data.prescription.medication ? [{
                    label: e.data.prescription.medication,
                    amount: Number(e.data.prescription.amount) || 1
                }] : []));

                $("#date").text(GetDateString(e.data.date * 1000));
                $("body").show();
                break;
        };
    });

    nuifetch('load_config');
});

function SubmitPrescription(): void {
    let data: Record<string, unknown> = {};
    $(".data").each(function(this: HTMLElement, _index: number, _element: HTMLElement): void {
        const key = $(this).attr("id") as string;
        data[key] = $(this).val();
    });
    data.medications = medications;
    if (medications[0]) {
        data.medication = medications[0].label;
        data.amount = medications[0].amount;
    }
    console.log("sending data to lua");
    nuifetch("submit_prescription", data);
    CancelPrescription(null, false);
}

function CancelPrescription(_e?: Event | null, keepOpen?: boolean): void {
    $(".data").each(function(this: HTMLElement, _index: number, _element: HTMLElement): void {
        $(this).val("");
    });
    setMedications([]);
    $(".medication-open").prop("disabled", false);
    closeMedicationPicker();
    if (!keepOpen) {
        $("body").hide();
        nuifetch("nuiClosed");
    };
}


/**
 * Return either the current date, or date based on given timestamp in local format
 * @param timestamp optional unix timestamp
 * @returns String representing date in local format
 */
function GetDateString(timestamp?: number): string {
    let date: Date;
    if (timestamp) date = new Date(timestamp);
    else date = new Date();

    try {
        return date.toLocaleDateString(Config.locale);
    } catch (e) {
        return date.toLocaleDateString("en-US"); // fallback in case of invalid locale string
    }
}
