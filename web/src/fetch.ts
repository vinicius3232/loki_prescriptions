export async function nuifetch(event: string, data: any = {}): Promise<any> {
    try {
        const response = await fetch(`https://${(window as any).GetParentResourceName()}/${event}`, {
            method: 'POST',
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: JSON.stringify({data}),
        });
        const result = response.json();
        return result;
    }
    catch {
        return null;
    }
}
